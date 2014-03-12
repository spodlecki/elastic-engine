module ElasticEngine
  module Search
    class BaseFacets
      include BaseFacetsConfig

      def facets
        self.class.facets
      end

      # Query String Search
      # Field can be a string or an array. If it is an array, it will process as a multi_match query
      # At the moment, param: does nothing. Planned for the future, customize the param passed
      # {
      #   field: ['name.ac','name.ac_word'],
      #   param: :term
      # }
      def query_string_search
        nil
      end

      # Default filter is to be used to set a default up.
      # Use it to restrict results globally, such as a 
      # 'published' flag
      # ret = Array.new
      # ret << { :type => { :value => 'banner' } }
      # ret << { :term => { :published => true } }
      # ret
      def default_filter
        []
      end
      
      # Default sorts configuration
      # [
      #   { value: 24, default: true },
      #   { value: 32 },
      #   { value: 40 },
      #   { value: 64 }
      # ]
      #
      def available_limits
        []
      end

      # Build select box values for limits
      #
      def limits_for_form
        available_limits.collect{|x| x.fetch(:value, nil)}.reject(&:nil?) || []
      end

      # Default sorts configuration
      # [
      #   {
      #     label: "Recent",
      #     value: "updated",
      #     search: { updated_at: {order: :desc} },
      #     default: true
      #   },
      #   {
      #     label: "Alpha",
      #     value: "alpha",
      #     search: { :'name.exact' => {order: :asc} }
      #   }
      # ]
      #
      def available_sorts
        []
      end
      
      # Build select box values
      #
      def sorts_for_form
        available_sorts.map{|sort| [sort.fetch(:label, ''), sort.fetch(:value,'')] } || []
      end

      # Default order is to be used to set a default up.
      # **** depreciated ****
      # Will call available_sorts as a fall back for the time being
      #
      def default_order
        h.select{|x| x.fetch(:default, false)}.first || {}
      end
    end
  end
end