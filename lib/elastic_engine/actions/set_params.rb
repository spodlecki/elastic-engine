module ElasticEngine
  module Actions
    # Pass params to module. Using Strong Parameters is recommended
    #
    def set_params(params)
      @params = Search::Params.new(self, params)
      self
    end
  end
end