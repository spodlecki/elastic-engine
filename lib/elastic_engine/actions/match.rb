module ElasticEngine
  module Actions

    # Apply a match query to ES
    # {__field}   [STRING]    ~ Actual field to search (example: 'keywords.id')
    # {__string}  [STRING]    ~ Raw string to search for. No validations applied
    # {__options} [HASH]      ~ Additional options you wish to attach to the query. Many options at the link below
    #                           @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-match-query.html
    # {__match_type} [STRING] ~ Apply an alternate match_type to the query [:match, :match_phrase, :match_phrase_prefix]
    #
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
  end
end