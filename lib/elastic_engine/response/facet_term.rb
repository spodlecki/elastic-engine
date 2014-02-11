module ElasticEngine
  module Response
    class FacetTerm
      OPERATOR_MAPPING = {
        and: ',',
        or: '|'
      }

      attr_reader :id, :count, :term, :group

      def initialize(args)
        @id = args[:id].to_s.downcase
        @count = args[:count]
        @term = args[:term]
        @group = args[:group]
      end
      def name
        @term
      end

      def group_param_values
        @group_params ||= group.group_param_values
      end
      def operator(op=:or)
        OPERATOR_MAPPING[op]
      end
      def selected?
        !!group_param_values.include?(@id)
      end

      def url_params
        if selected?
          case group.operator
          when 'multivalue' then remove_multivalue
          when 'multivalue_and' then remove_multivalue(:and)
          when 'multivalue_or'  then remove_multivalue(:or)
          when 'exclusive_or'   then remove_singlevalue
          # else                  raise UnknownSelectableType.new "Unknown selectable type for #{param_key} in #{group.type}"
          end
        else
          case group.operator
          when 'multivalue'     then add_multivalue
          when 'multivalue_and' then add_multivalue(:and)
          when 'multivalue_or'  then add_multivalue(:or)
          when 'exclusive_or'   then add_singlevalue
          # else                  raise UnknownSelectableType.new "Unknown selectable type #{selectable_type} for #{@type}"
          end
        end
      end

      def remove_multivalue(logical_operator=nil)
        logical_operator = group.operator_for# if logical_operator.nil?

        p = group.group_param_values
        if p.count <= 1
          remove_singlevalue
        else
          p = p.map{|value| value unless !!(value === @id) }
          { group.key.to_sym => p.delete_if(&:nil?).join( operator(logical_operator) ) }
        end
      end

      def remove_singlevalue
        {}
      end

      def add_multivalue(logical_operator=nil)
        logical_operator = group.operator_for# if logical_operator.nil?

        if group_param_values.empty?
          add_singlevalue
        else
          { group.key.to_sym => [@id, group_param_values].join( operator(logical_operator) ) }
        end
      end

      def add_singlevalue
        { group.key.to_sym => @id }
      end
    end
  end
end
