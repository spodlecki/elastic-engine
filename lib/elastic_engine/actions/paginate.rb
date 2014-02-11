module ElasticEngine
  module Actions

    # Paginate a query
    # {__page}     [INT]    ~ Which page ?
    # {__per}      [INT]    ~ How many per page?
    #
    def paginate(__page = 1, __per = 55)
      __page = Support::Utils.__validate_integer(__page.to_i, 1)
      __per = Support::Utils.__validate_integer(__per.to_i, 55)

      @query[:body].merge! size: [__per, 1].max, from: [__per, 1].max * ([__page, 1].max - 1)
      self
    end
  end
end