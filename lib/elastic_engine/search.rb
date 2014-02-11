module ElasticEngine
  module Search
    class Base
      include ElasticEngine::Actions

      attr_reader :client, :params, :query,
                  :index, :types
      
      # Initialize a basic search builder
      # {type}        ~ A specific type (or types) in the ElasticSearch Index, if it is AR Model, then its usually the Class.name.downcase
      # {index}       ~ If you have multiple indexes, delcare which ES index to use. By default, it selects what your config says to use
      def initialize(args)
        raise "Arguents need to be a hash when initializing search!" unless args.is_a?(Hash)
        @client = Configuration.client
        @index = args[:index] || Configuration.index
        @types = args[:type]

        @query = { index: @index, type: @types, body: {} }
      end
      
      def execute!
        client.search(@query)
      end

      # Perform the actual search
      # ElasticEngine::Search::Base.new.<search options>.search
      def search
        Response::Response.new(self)
      end
    end
  end
end