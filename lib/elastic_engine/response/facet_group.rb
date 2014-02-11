module ElasticEngine
  module Response
    class FacetGroup
      attr_reader :search, :key, :title, :operator,
                  :result_terms
      
      # Initialize the FacetGroup
      # {search} [ElasticEngine::Search::Faceted]   ~ We can access the original search object via 'search'
      # {key}     [STRING]                          ~ the name given to ElasticSearch for facets
      # {facet_data}          [HASH]                ~ The raw facet result from ElasticSearch
      def initialize(search, key, facet_data)
        @search = search
        @key = key.to_sym
        @result_terms = result_hit_mapping(facet_data['terms'])
        find_title_and_operator
      end

      # Collection of facets
      # 
      def terms
        @terms ||= build_term_values
      end

      # Returns the array of current values
      #
      def group_param_values
        @group_param_values ||= group_param_string.split(/[#{FacetTerm::OPERATOR_MAPPING.values.join}]/)
      end

      # Returns string of current values
      #
      def group_param_string
        @group_param_string ||= search.params.fetch_params_for(@key)
      end

      # Determines operator (and/or) for current selection
      #
      def operator_for
        search.params.select_operator(group_param_string)
      end

      private

        # Returns the title & operator of the facet group
        # This is applied within the Facet Configs
        #
        def find_title_and_operator
          @title = nil
          @operator = nil
          return nil unless search.facet_klass.respond_to?(:facets)

          __res = search.facet_klass.facets.select{|key,v| key.to_s.downcase == @key.to_s.downcase }
          return unless __res
          @title = __res[@key].fetch(:title, @key.to_s.humanize)
          @operator = __res[@key].fetch(:operator, nil)
        end
        
        # Build out our facet terms. If no facet configuration is found, we will just use ElasticSearch's fields.
        #
        def build_term_values
          term_values = fetch_facet_terms_for(@key)
          # Return basic elasticsearch result terms if we dont have method defined
          return generate_facet_terms_by_result unless term_values.any?

          term_values.map { |term| FacetTerm.new(group: self, id: term.fetch(:id), term: term.fetch(:term), count: fetch_count_for( term.fetch(:id) ) ) }
        end

        # Returns hash from Facets Configuration
        # { id: <indentifier>, term: <term>}
        #
        def fetch_facet_terms_for(facet_group_name)
          search.facet_klass.send("faceted_#{facet_group_name}", search.facet_arguments.fetch(facet_group_name.to_sym, nil) ) if search.facet_klass.respond_to?("faceted_#{facet_group_name}".to_sym)
        end
        def generate_facet_terms_by_result
          @result_terms.map { |facet_term,facet_count| FacetTerm.new(id: facet_term, term: facet_term, count: facet_count) }
        end
        
        # Matches ElasticSearch's facet result res["term"] to a specific id passed through
        # This allows us to match a preset facet group to a result
        #
        def fetch_count_for(id)
          @result_terms.fetch(id.to_s.downcase, 0)
        end
        
        # Occationally ElasticSearch will return boolean facets with mix cased characters (T/t & F/f)
        # This method cleans this result and combines the counts to be correct & valid
        #
        def result_hit_mapping(result_facets)
          @mapping ||= result_facets.each_with_object(Hash.new(0)) do |result, hash|
            term = result['term']
            term = term.to_s.downcase
            hash[term] += result['count']
          end
        end
    end
  end
end
