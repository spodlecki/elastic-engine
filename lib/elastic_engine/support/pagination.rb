module ElasticEngine
  module Support
    module Pagination
      def self.included(base)
        # Include the Kaminari configuration and paging method in response
        #
        base.__send__ :include, ::Kaminari::ConfigurationMethods::ClassMethods
        base.__send__ :include, ::Kaminari::PageScopeMethods
      end

      # # Returns the current "limit" (`size`) value
      # #
      def limit_value
        case
          when search.query[:body] && search.query[:body][:size]
            search.query[:body][:size]
          when search.query[:size]
            search.query[:size]
          else
            0
        end
      end

      # # Returns the current "offset" (`from`) value
      # #
      def offset_value
        case
          when search.query[:body] && search.query[:body][:from]
            search.query[:body][:from]
          when search.query[:from]
            search.query[:from]
          else
            0
        end
      end

      # Returns the total number of results
      #
      def total_count
        results.total
      end
    end
  end
end
