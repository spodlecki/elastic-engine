module ElasticEngine
  module Search
    class Params
      attr_reader :search, :terms
      
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
        @terms = whitelisted_and_validated_params(params)
      end

      # Fetch current params for a given facet
      #
      def fetch_params_for(key)
        @terms.fetch(key.to_sym, '')
      end

      # Cycle mappings to find the current selector. Defaults to :or
      #
      def select_operator(values)
        self.class.operators.each do |k,v|
          return k if values.include?(v)
        end
        :or
      end

      # Initial building for faceted search. This will apply given filters based on params passed to the search engine
      # TODO; Validate values for each term. Should perform common checks is_integer, is_alpha
      #
      def build_search_facet_filters(facets)
        facets.each do |k,v|
          values = fetch_params_for(k)
          next if values.blank?
          _operator = select_operator(values)

          search.filter_with_execution(v[:field], values.split( self.class.operator_split(_operator) ).map{|t| set_elasticsearch_value(t) }.uniq, :and, :terms, _operator)
        end
      end

    private
      # TODO; Whitelist specific params. This may be best served via the controller though using Strong Params
      #
      def whitelisted_and_validated_params(terms)
        terms
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