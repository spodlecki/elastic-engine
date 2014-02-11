module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    # Set up the mapping
    #
    settings index: { number_of_shards: 1, number_of_replicas: 0 } do
      mapping do
        indexes :name,      analyzer: 'snowball'
        indexes :created_at, type: 'date'

        indexes :tags, type: 'multi_field' do
          indexes :name
          indexes :id
        end

        indexes :body_type
      end
    end

    # Customize the JSON serialization for Elasticsearch
    #
    def as_indexed_json(options={})
      {
        id: title,
        name: name,
        created_at:  created_at,
        body_type:    body_type.as_json(only: [:name, :id]),
        tags:   tags.as_json(only: [:name, :id])
      }
    end

    # Update document in the index after touch
    #
    after_touch() { __elasticsearch__.index_document }
  end
end