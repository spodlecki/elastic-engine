module ElasticEngine
  module Response

    # Encapsulates the collection of documents returned from Elasticsearch
    #
    # Implements Enumerable and forwards its methods to the {#results} object.
    #
    class Results
      attr_reader :response

      include Enumerable
      extend  Support::Forwardable
      forward :results, :each, :empty?, :size, :slice, :[], :to_a, :to_ary

      def initialize(response)
        @response  = response
      end

      # Returns the {Results} collection
      #
      def results
        @results  = response.response['hits']['hits'].map { |hit| Result.new(hit) }
      end
      
      # Returns the total number of hits
      #
      def total
        response.response['hits']['total']
      end

      # Returns the max_score
      #
      def max_score
        response.response['hits']['max_score']
      end
    end
  end
end
