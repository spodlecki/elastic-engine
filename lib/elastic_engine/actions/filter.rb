module ElasticEngine
  module Actions
    # Add a filter to the query
    # {__field}     [STRING]    ~ Actual field to search (example: 'keywords.id')
    # {__value}     [MIXED]     ~ Value to search for
    # {__operator}  [STRING]    ~ Apply the operator to the filter group [:and,:or,:not]
    # {__type}      [STRING]    ~ Apply a type of filter [:term,:terms,:prefix,:type,:ids,:range,:missing,:exists]
    # {__execution}  [STRING]   ~ Search execution [:and, :or] that applies to the specific filter
    # @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-filters.html
    #
    def filter(__field, __value, __operator=:and, __type=:term, __execution=nil)
      __operator = Support::Utils.__validate_selection_with_raise(__operator.to_sym, Support::Utils::FILTER_OPERATORS)
      __type = Support::Utils.__validate_selection_with_raise(__type.to_sym, Support::Utils::FILTER_TYPES)
      __execution = Support::Utils.__validate_selection_with_raise(__execution.to_sym, Support::Utils::EXEC_TYPES) if __execution

      __value = __value.is_a?(String) ? __value.downcase : __value

      __filter = {
        __type.to_sym => {
          __field.to_sym => __value
        }
      }
      __filter[__type.to_sym][:execution] =  __execution.to_s if __execution

      @query[:body][:filter] ||= {}
      @query[:body][:filter][__operator.to_sym] ||= []
      @query[:body][:filter][__operator.to_sym] << __filter
      self
    end

    # Fetch filters hash
    #
    def _filters
      @query[:body].fetch(:filter, nil)
    end
  end
end