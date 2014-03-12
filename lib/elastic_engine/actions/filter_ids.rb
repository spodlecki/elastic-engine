module ElasticEngine
  module Actions
    # Filter IDs on the query
    # @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-filters.html
    #
    def filter_ids(_ids, _type=nil)
      @query[:body][:filter] ||= {}
      raise "Filtering IDs require an Array" unless _ids.is_a?(Array)

      __filter = {
        ids: {
          values: _ids
        }
      }
      # Add a type if it is specified
      __filter[:ids][:type] =  _type.to_s if _type

      @query[:body][:filter].merge!(__filter)

      self
    end

    # Fetch filters hash
    #
    def _filters
      @query[:body].fetch(:filter, nil)
    end
  end
end