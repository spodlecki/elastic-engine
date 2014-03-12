module ElasticEngine
  module Actions

    # Apply a match query to ES
    # {__fields}   [STRING]    ~ Actual field to search (example: 'keywords.id')
    # {__string}  [STRING]    ~ Raw string to search for. No validations applied
    # {__options} [HASH]      ~ Additional options you wish to attach to the query. Many options at the link below
    #                           @ http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/query-dsl-match-query.html
    # {__match_type} [STRING] ~ Apply an alternate match_type to the query [:match, :match_phrase, :match_phrase_prefix]
    #
    def multi_match(__fields, __string, __options = {}, __match_type = :match)
      __match_type = Support::Utils.__validate_selection_with_raise(__match_type.to_sym, Support::Utils::MATCH_TYPES)
      __fields = [__fields] unless __fields.is_a?(Array)
      __string = Support::Utils.sanitize_string_for_elasticsearch_string_query(__string)
      
      @query[:body][:query] ||= {}
      @query[:body][:query].merge!({
        multi_match: {
          fields: __fields,
          query: __string
        }.merge(__options)
      })
      self
    end
  end
end