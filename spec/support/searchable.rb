module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    index_name 'test_fakeapplication'

    after_save {  __elasticsearch__.index_document }
    before_destroy {  __elasticsearch__.delete_document }
    after_touch() { __elasticsearch__.index_document }

    # Set up the mapping
    #
    settings index: { number_of_shards: 1, number_of_replicas: 0 } do
      mapping do
        indexes :name,      analyzer: 'snowball'
        indexes :created_at, type: 'date'

        indexes :tags, type: 'object' do
          indexes :name
          indexes :id
        end

        indexes :body_types, type: 'object' do
          indexes :name
          indexes :id
        end
      end
    end

    # Customize the JSON serialization for Elasticsearch
    #
    def as_indexed_json(options={})
      {
        id: id,
        name: name,
        body_types: body_types.map{ |x| {id: x.id, name: x.name} },
        tags: tags.map{ |x| {id: x.id, name: x.name} },
        created_at: created_at
      }
    end
  end
end