module ElasticEngine
  module Actions

    # Apply a match_all query to ES
    # This is the most common query for a filter search / facet search.
    # It is automatically applied in the event no query is set.
    #
    def match_all
      @query[:body].merge! query: { match_all: {} }
      self
    end
  end
end