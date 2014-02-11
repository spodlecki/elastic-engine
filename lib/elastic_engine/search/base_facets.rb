module ElasticEngine
  module Search
    class BaseFacets
      include BaseFacetsConfig

      def facets
        self.class.facets
      end
      # Default filter is to be used to set a default up.
      # Use it to restrict results globally, such as a 
      # 'published' flag
      # ret = Array.new
      # ret << { :type => { :value => 'banner' } }
      # ret << { :term => { :published => true } }
      # ret
      def default_filter

      end
    end
  end
end