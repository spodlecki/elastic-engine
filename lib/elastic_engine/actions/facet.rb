module ElasticEngine
  module Actions
    # Add a facet to the query
    # {name}   ~ A Title for the facets (example: 'keywords')
    # {field}  ~ Actual field to search (example: 'keywords.id')
    def facet(name, field)
      @query[:body][:facets] ||= {}
      @query[:body][:facets].merge!({
          name.to_sym => {
            terms: {
              field: field
            }.merge(size: 70)
          }
      })
      self
    end

    # Fetch facets Hash
    #
    def _facets
      @query[:body].fetch(:facets, nil)
    end
  end
end