# TODO;
# Break this up into a query DSL for elastic search
module ElasticEngine
  module Search
    class Faceted < Base
      attr_reader :filter_facets, :facet_config_type, :facet_arguments,
                  :params

      # Initialize a faceted search to ElasticSearch
      # {type}             ~ A specific type (or types) in the ElasticSearch Index, if it is AR Model, then its usually the Class.name.downcase
      # {index}            ~ If you have multiple indexes, delcare which ES index to use. By default, it selects what your config says to use
      # {filter_facets}    ~ By default, we treat facet search as faceted navigation. Which is to say, we filter the facet counts as 
      #                        users select new values. To keep counts based on the query only, turn this off
      # {facet_config}     ~ The app will automatically attempt to determine the facet configs name, but if its special -- declare it or facets won't work.
      # {facet_arguments}  ~ Trickery. This is used to pass special information to the facet config files.
      #                       Provide method with a hash:
      #                       { <facet_name>: {<hash_of_arguments} }
      def initialize(args)
        super(args)

        @facet_config_type  = args[:facet_config_type] || args[:type]
        @facet_arguments = args[:facet_arguments] || {}
        @filter_facets = args[:filter_facets] || true
        @params = Search::Params.new(self, args[:params].try(:to_hash)) if args[:params]

        __load_custom_facet_configuration
      end
      
      def facet_klass
        @facet_klass ||= begin
          "#{@facet_config_type.classify}Facets".constantize.new
        rescue
          "ElasticEngine::Search::BaseFacets".constantize.new
        end
      end
      # Perform query to elastic search server(s)
      #
      def search
        prepare_facet_filters!
        super
      end

    private
      # If you are performing a faceted navigation, you'll need to run the facet_filter on all facets
      # @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/search-facets.html#_facet_filter
      # By default, this occurs when we have facets AND filters applied to the search query.
      # You can turn this off by initializing with __filter_facets equal to false
      def prepare_facet_filters!
        # TODO; This could explode....??
        return unless @filter_facets && @query[:body][:facets] && @query[:body][:filter]
        @query[:body][:facets].each do |k,v|
          @query[:body][:facets][k].merge!({
            facet_filter: @query[:body][:filter]
          })
        end
      end
      def __load_custom_facet_configuration
        return unless @facet_config_type =~ /\A[a-z_]+\z/
        facet_klass.facets.each do |k,v|
          facet(k, v[:field])
        end
        apply_default_filters
        apply_default_orders
        apply_facet_filters
      end
      def apply_facet_filters
        @params && @params.build_search_facet_filters(facet_klass)
      end
      def apply_default_filters
        facet_klass.default_filter.each do |f|
          @query[:body][:filter] ||= {}
          @query[:body][:filter][:and] ||= []

          @query[:body][:filter][:and] << f
        end if @facet_klass.default_filter.any?
      end
      def apply_default_orders
        facet_klass.default_order.each do |k,v|
          order(k, v[:order])
        end if facet_klass.default_order.any?
      end
    end
  end
end