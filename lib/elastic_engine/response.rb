module ElasticEngine
  # Contains modules and classes for wrapping the response from Elasticsearch
  #
  module Response

    # Encapsulate the response returned from the Elasticsearch client
    #
    # Implements Enumerable and forwards its methods to the {#results} object.
    #
    class Response
      attr_reader :klass, :search, :response,
                  :took, :timed_out, :shards,
                  :query

      include Enumerable
      extend  ElasticEngine::Support::Forwardable
      include ElasticEngine::Support::Pagination

      # forward :results, :each, :empty?, :size, :slice, :[], :to_ary

      def initialize(search)
        @search = search
      end

      # Returns the Elasticsearch response
      #
      # @return [Hash]
      #
      def response
        @response ||= search.execute!
      end

      # Returns the collection of "hits" from Elasticsearch
      #
      # @return [Results]
      #
      def results
        @results ||= Results.new(self)
      end

      # Returns the {Facets} collection
      def facets
        @facets ||= facet_groups
      end
      # Returns the hash that was sent to ElasticSearch
      def query
        @query ||= search.query
      end
      # Returns the "took" time
      #
      def took
        response['took']
      end

      # Returns whether the response timed out
      #
      def timed_out
        response['timed_out']
      end

      # Returns the statistics on shards
      #
      def shards
        Hashie::Mash.new(response['_shards'])
      end
      private
        def facet_groups
          return [] unless response['facets']
          response['facets'].map { |name, facet_data| FacetGroup.new(search, name, facet_data) }
        end
    end
  end
end