# TODO;
# Break this up into a query DSL for elastic search
module ElasticEngine
  module Search
    class Base
      attr_reader :client, :params, :query,
                  :index, :types
      
      # Initialize a basic search builder
      # {type}        ~ A specific type (or types) in the ElasticSearch Index, if it is AR Model, then its usually the Class.name.downcase
      # {index}       ~ If you have multiple indexes, delcare which ES index to use. By default, it selects what your config says to use
      def initialize(args)
        raise "Arguents need to be a hash when initializing search!" unless args.is_a?(Hash)
        @client = Configuration.client
        @index = args[:index] || Configuration.index
        @types = args[:type]

        @query = { index: @index, type: @types, body: {} }
      end

      # Apply a match query to ES
      # {__field}   [STRING]    ~ Actual field to search (example: 'keywords.id')
      # {__string}  [STRING]    ~ Raw string to search for. No validations applied
      # {__options} [HASH]      ~ Additional options you wish to attach to the query. Many options at the link below
      #                           @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-match-query.html
      # {__match_type} [STRING] ~ Apply an alternate match_type to the query [:match, :match_phrase, :match_phrase_prefix]
      def match(__field, __string, __options = {}, __match_type = :match)
        __match_type = Support::Utils.__validate_selection_with_raise(__match_type.to_sym, Support::Utils::MATCH_TYPES)
        @query[:body][:query] ||= {}
        @query[:body][:query].merge!({
          :"#{__match_type}" => {
            :"#{__field}" => __string
          }.merge(__options)
        })
        self
      end

      # Apply a match_all query to ES
      # This is the most common query for a filter search / facet search.
      # It is automatically applied in the event no query is set.
      def match_all
        @query[:body].merge! query: { match_all: {} }
        self
      end

      # Apply an ordered query
      # {__field}     [STRING]    ~ Actual field to search (example: 'keywords.id')
      # {__direction} [STRING]    ~ Just like a SQL Query, [:asc,:desc]
      def order(__field, __direction = :asc)
        __direction = Support::Utils.__validate_selection_with_raise(__direction.to_sym, Support::Utils::SORT_DIRECTIONS)
        @query[:body][:sort] ||= []
        @query[:body][:sort] << { __field.to_sym => {order: __direction}}
        self
      end

      # Paginate a query
      # {__page}     [INT]    ~ Which page ?
      # {__per}      [INT]    ~ How many per page?
      def paginate(__page = 1, __per = 55)
        __page = Support::Utils.__validate_integer(__page.to_i, 1)
        __per = Support::Utils.__validate_integer(__per.to_i, 55)

        @query[:body].merge! size: [__per, 1].max, from: [__per, 1].max * ([__page, 1].max - 1)
        self
      end

      def filter_with_execution(__field, __value, __operator=:and, __type=:term, __execution=:or)
        filter(__field, __value, __operator, __type, __execution)
        self
      end
      # Add a filter to the query
      # {__field}     [STRING]    ~ Actual field to search (example: 'keywords.id')
      # {__value}     [MIXED]     ~ Value to search for
      # {__operator}  [STRING]    ~ Apply the operator to the filter group [:and,:or,:not]
      # {__type}      [STRING]    ~ Apply a type of filter [:term,:terms,:prefix,:type,:ids]
      # {__execution}  [STRING]   ~ Search execution [:and, :or] that applies to the specific filter
      # @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-filters.html
      def filter(__field, __value, __operator=:and, __type=:term, __execution=nil)
        __operator = Support::Utils.__validate_selection_with_raise(__operator.to_sym, Support::Utils::FILTER_OPERATORS)
        __type = Support::Utils.__validate_selection_with_raise(__type.to_sym, Support::Utils::FILTER_TYPES)
        __execution = Support::Utils.__validate_selection_with_raise(__execution.to_sym, Support::Utils::EXEC_TYPES) if __execution

        __value = __value.is_a?(String) ? __value.downcase : __value

        __filter = {
          __type.to_sym => {
            __field.to_sym => __value
          }
        }
        __filter[__type.to_sym][:execution] =  __execution.to_s if __execution

        @query[:body][:filter] ||= {}
        @query[:body][:filter][__operator.to_sym] ||= []
        @query[:body][:filter][__operator.to_sym] << __filter
        self
      end
      def execute!
        client.search(@query)
      end

      # Perform the actual search
      # ElasticEngine::Search::Base.new.<search options>.search
      def search
        Response::Response.new(self)
      end
    end
  end
end