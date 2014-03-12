module ElasticEngine
  module Actions

    # Limit a query
    # {limit_count}      [INT]    ~ How many?
    #
    def limit(limit_count)
      limit_count = Support::Utils.__validate_integer(limit_count.to_i, 1)

      @query[:body].merge! size: [limit_count, 1].max
      self
    end
  end
end