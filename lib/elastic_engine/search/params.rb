module ElasticEngine
  module Search
    class Params
      attr_reader :search, :terms,
                  :sort, :limit, :query_string
      
      # Returns hash of available operators
      #
      def self.operators
        ElasticEngine::Response::FacetTerm::OPERATOR_MAPPING
      end

      # Returns the split character based on selection
      # Default to OR
      #
      def self.operator_split(operation)
        operators.fetch(operation.to_sym, operators[:or])
      end
      
      # When passing params, make sure to use Strong Params.
      #
      def initialize(search, params)
        @search = search
        @terms = whitelist_and_validate_params(params)
        
        # TODO; Custom sort variable
        @sort = validate_sort_param(params["sort"])

        # TODO; Custom limit param
        @limit = validate_limit_param(params["limit"])

        # TODO; Custom query param
        @query_string = validate_query_string(params["term"])
      end

      # Fetch current params for a given facet
      #
      def fetch_params_for(key)
        @terms.fetch(key.to_sym, '')
      end

      # Get the operator for a specific param key
      #
      def fetch_operator_for(faceted_config_operator, values)
        case faceted_config_operator
          when "multivalue"
            select_operator_key(values)
          when "multivalue_and"
            :and
          when "multivalue_or"
            :or
          when "exclusive_or"
            nil
        end
      end

      # Cycle mappings to find the current selector. Defaults to :or
      #
      def select_operator_key(values)
        self.class.operators.each do |k,v|
          return k if values.include?(v)
        end
        :or
      end

      # Initial building for faceted search. This will apply given filters based on params passed to the search engine
      # {facets_klass}        ~ Facet Config Class (from README ex: "PersonFacet")
      #
      def build_search_facet_filters(facets_klass)
        facets_klass.facets.each do |facet_key,facet_config|
          # Gather values from params
          values = fetch_params_for(facet_key)
          next if values.blank? #dont process blank params, can create blank pills, which is ugly UX

          _operator = fetch_operator_for(facet_config[:type], values)
          
          values = values.split(/[#{Response::FacetTerm::OPERATOR_MAPPING.values.join}]/) unless _operator.nil?

          # apply search filter for the facet
          search.filter_with_execution(
            facet_config[:field],
            values,
            :and,
            values.is_a?(Array) ? :terms : :term,
            _operator
          ) unless values.empty?
        end
      end
      
      # Build the query for ordering
      #
      def build_order(facet_klass)
        return if sort.nil?
        sort.fetch(:search, []).each do |k,v|
          search.order(k, v.fetch(:order, :desc))
        end
      end

      # Apply a limit to the search based on params
      #
      def build_limit(facet_klass)
        return if limit.nil? || (search.query && search.query.fetch(:body) && search.query[:body].fetch(:size, false))
        search.limit(limit)
      end

      # Apply a query string search based on config
      def build_query_string_search(facet_klass)
        return unless query_string && search.facet_klass.respond_to?(:query_string_search) && search.facet_klass.query_string_search

        fields = search.facet_klass.query_string_search.fetch(:field)
        
        search.multi_match(fields, query_string) if fields.is_a?(Array) && fields.any?
        search.match(fields, query_string) if fields.is_a?(String)
      end
    private
      def validate_query_string(query_string_value)
        return nil unless !!(query_string_value =~ /[^\s]{1,}/)
        query_string_value
      end
      # Run the sort param through a validation
      #
      def validate_sort_param(sort_param_value)
        return sort_param_value unless search.facet_klass.respond_to?(:available_sorts)
        # Get selected sort
        _sort_ = search.facet_klass.available_sorts.select{|x| x.fetch(:value, '') == sort_param_value }.first
        # Get default if no sort existed
        _sort_ = search.facet_klass.available_sorts.select{|x| x.fetch(:default, false) }.first unless _sort_
        # Grab the first sort if none of the above apply
        _sort_ = search.facet_klass.available_sorts.first unless _sort_
        _sort_
      end

      # Run the limit param through a validation process
      # Fall back to defaults if nothing applies
      #
      def validate_limit_param(limit)
        # Just give the limit of the request if there is no facet_klass
        return limit unless search.facet_klass.respond_to?(:available_limits)

        if search.facet_klass.limits_for_form.include?(limit.to_i)
          limit.to_i
        else
          _default_ = search.facet_klass.available_limits.select{|x| x.fetch(:default, false) }.first
          # If default does not exist, select the first
          _default_ = search.facet_klass.available_limits.first unless _default_
          _default_.fetch(:value, nil)
        end
      rescue
        nil
      end

      def whitelist_and_validate_params(params)
        return params unless search.facet_klass.respond_to?(:facets)
        whitelisted_params = Hash.new

        params.each do |param_key,param_value|
          facet = search.facet_klass.facets.select{|facet_key,facet_config_values| param_key.to_s == facet_key.to_s}
          next unless facet.any?
          facet_config = facet.fetch(param_key.to_sym, nil)
          next unless facet_config
          _operator = fetch_operator_for(facet_config[:type], param_value)
          whitelisted_params.merge!(param_key.to_sym => validated_param_values(search.facet_klass, param_key, _operator, param_value))
        end
        whitelisted_params
      end

      # Method validated_param_values
      # {facets_klass} [Facet Config]         ~ <type>Facets config class
      # {facet_key} [SYMBOL]                  ~ The name of the facet
      # {_operator} [SYMBOL/NIL]              ~ Defined by the type of facet
      # {values}     [STRING]                 ~ The entire string from the params
      #
      def validated_param_values(facets_klass, facet_key, _operator, values)        
        _split_values_with = _operator ? self.class.operator_split(_operator) : ''
        values = _split_values_with.blank? ? [values] : values.split(_split_values_with)
        values.map!{|v| set_elasticsearch_value(v) }

        values.reject!{|v| !facets_klass.public_send("faceted_#{facet_key}_validation", v) } if facets_klass.respond_to?(:"faceted_#{facet_key}_validation")
        values.uniq.join(_split_values_with)
      end

      # ElasticSearch returns a t/f for a boolean, we convert this back to a TrueFalseClass for the query filters
      def set_elasticsearch_value(term)
        case term.downcase
        when 't' then true
        when 'f' then false
        else     term
        end
      end
    end
  end
end