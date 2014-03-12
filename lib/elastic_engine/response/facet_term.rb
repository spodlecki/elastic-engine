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
        @selected ||= !!group_param_values.include?(translate_id)
      end

      def url_params
        if selected?
          case group.type
          when 'multivalue' then remove_multivalue
          when 'multivalue_and' then remove_multivalue(:and)
          when 'multivalue_or'  then remove_multivalue(:or)
          when 'exclusive_or'   then remove_singlevalue
          # else                  raise UnknownSelectableType.new "Unknown selectable type for #{param_key} in #{group.type}"
          end
        else
          case group.type
          when 'multivalue'     then add_multivalue
          when 'multivalue_and' then add_multivalue(:and)
          when 'multivalue_or'  then add_multivalue(:or)
          when 'exclusive_or'   then add_singlevalue
          # else                  raise UnknownSelectableType.new "Unknown selectable type #{selectable_type} for #{@type}"
          end
        end
      end

      # For pills, we do not want to show unselected values
      # Make sure to check if you are doing individual pills
      #
      def build_pill?
        !!selected?
      end

      # Text to use for the pill label
      #
      def pill_text
        build_pill? ? name : nil
      end

      # URL Params to merge in for the pill
      #
      def pill_url
        build_pill? ? url_params : nil
      end

      # Removing a value from the parameters
      # Example:
      #   group.group_param_values = '1|3|4'
      #   self.id = 3
      # => {group.key.to_sym => '1|4'}
      def remove_multivalue(logical_operator=nil)
        logical_operator ||= group.operator_for

        p = group.group_param_values
        if p.count <= 1
          remove_singlevalue
        else
          p = p.map{|value| value unless !!(value === @id) }
          { group.key.to_sym => p.delete_if(&:nil?).join( operator(logical_operator) ) }
        end
      end
      
      # Remove a single value from the group_param_values
      #
      def remove_singlevalue
        {}
      end

      # Adding a value to the parameters
      # Example:
      #   group.group_param_values = '1|3|4'
      #   self.id = 7
      # => {group.key.to_sym => '1|3|4|7'}
      def add_multivalue(logical_operator=nil)
        logical_operator ||= group.operator_for

        if group_param_values.empty?
          add_singlevalue
        else
          { group.key.to_sym => [@id, group_param_values].join( operator(logical_operator) ) }
        end
      end

      # Adding a single value to the parameters
      # Example:
      #   group.group_param_values = '1'
      #   self.id = 7
      # => {group.key.to_sym => '7'}
      def add_singlevalue
        { group.key.to_sym => @id }
      end
    private
      def translate_id
        case @id
          when "t"
            "true"
          when "f"
            "false"
          else
            @id
        end
      end
    end
  end
end
