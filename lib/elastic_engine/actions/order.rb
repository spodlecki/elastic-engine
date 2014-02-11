module ElasticEngine
  module Actions
    
    # Apply an ordered query
    # {__field}     [STRING]    ~ Actual field to search (example: 'keywords.id')
    # {__direction} [STRING]    ~ Just like a SQL Query, [:asc,:desc]
    #
    def order(__field, __direction = :asc)
      __direction = Support::Utils.__validate_selection_with_raise(__direction.to_sym, Support::Utils::SORT_DIRECTIONS)
      @query[:body][:sort] ||= []
      @query[:body][:sort] << { __field.to_sym => {order: __direction}}
      self
    end
  end
end