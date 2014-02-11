module ElasticEngine
  module Actions

    # Add a filter to the query
    # {__field}     [STRING]    ~ Actual field to search (example: 'keywords.id')
    # {__value}     [MIXED]     ~ Value to search for
    # {__operator}  [STRING]    ~ Apply the operator to the filter group [:and,:or,:not]
    # {__type}      [STRING]    ~ Apply a type of filter [:term,:terms,:prefix,:type,:ids]
    # {__execution}  [STRING]   ~ Search execution [:and, :or] that applies to the specific filter
    # @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-filters.html
    #
    def filter_with_execution(__field, __value, __operator=:and, __type=:term, __execution=:or)
      filter(__field, __value, __operator, __type, __execution)
      self
    end
  end
end