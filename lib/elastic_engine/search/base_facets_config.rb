module ElasticEngine
  module Search
    module BaseFacetsConfig
      def self.included(klass)
        klass.instance_eval do
          extend ClassMethods
        end
      end

      module ClassMethods
        def facets
          @facets || []
        end
        def facet(name, field, type, title)
          @facets ||= {}
          @facets.merge!({
            name.to_sym => {
              field: field,
              type: type,
              title: title
            }
          })
        end
        def facet_multivalue(name, field, title = nil)
          facet(name, field, 'multivalue', title)
        end
        def facet_multivalue_and(name, field, title = nil)
          facet(name, field, 'multivalue_and', title)
        end
        def facet_multivalue_or(name, field, title = nil)
          facet(name, field, 'multivalue_or', title)
        end
        def facet_exclusive_or(name, field, title = nil)
          facet(name, field, 'exclusive_or', title)
        end
      end
    end
  end
end