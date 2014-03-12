module ElasticEngine
  module Actions
    
    # Add boolean query to search
    # {type}   ~ Type of bool match: [should|must|must_not]
    # {options}  ~ Query hash
    #
    def bool(type, options, minimum_number_should_match=1)
      type = Support::Utils.__validate_selection_with_raise(type.to_sym, Support::Utils::BOOL_TYPES)
      minimum_number_should_match = Support::Utils.__validate_integer(minimum_number_should_match, 1)

      raise "Boolean Query Options need to be a hash" unless options.is_a?(Hash)

      @query[:body][:query] ||= {}
      @query[:body][:query][:bool] ||= {}
      @query[:body][:query][:bool][type] ||= []
      @query[:body][:query][:bool][type] << options

      @query[:body][:query][:bool][:minimum_number_should_match] = minimum_number_should_match
      self
    end
  end
end