module ElasticEngine
  module Support
    module Utils
      extend ::Elasticsearch::API::Utils
      # Known options for elastic search (such as types, terms, match queries)
      MATCH_TYPES = [:match, :match_phrase, :match_phrase_prefix]
      FILTER_OPERATORS = [:and,:or,:not]
      FILTER_TYPES = [:term,:terms,:prefix,:type,:ids,:range,:missing]
      SORT_DIRECTIONS = [:asc, :desc]
      EXEC_TYPES = [:and,:or]
      BOOL_TYPES = [:should,:must,:must_not]
      
      def __validate_integer(int, default = 0, positive_only = true)
        int = int.try(:to_i) if int =~ /\A-?[0-9]+\z/

        return int if int.is_a?(Integer) && (positive_only && int > 0 || !positive_only)
        default
      end
      # Perform a validation on a specific selection. Will raise error in event the selection is invalid.
      # Personally, the raise is for development purposes. Use for validating ES specific method names
      # such as "match type"
      def __validate_selection_with_raise(argument, valid_params)
        raise ArgumentError, "URL parameter '#{argument}' is not supported" unless valid_params.include?(argument)
        argument
      end
      extend self
    end
  end
end