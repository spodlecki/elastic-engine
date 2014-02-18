module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    index_name 'test_fakeapplication'

    after_save {  __elasticsearch__.index_document }
    before_destroy {  __elasticsearch__.delete_document }
    after_touch() { __elasticsearch__.index_document }
  end
end