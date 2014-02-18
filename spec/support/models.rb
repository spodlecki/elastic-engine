class BodyType < ActiveRecord::Base
  has_and_belongs_to_many :people
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :people
  has_and_belongs_to_many :vehicles
end

class Person < ActiveRecord::Base
  include Searchable
  has_and_belongs_to_many :body_types
  has_and_belongs_to_many :tags

  # Set up the mapping
  #
  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :id, type: :integer
      indexes :name,      analyzer: 'snowball'
      indexes :created_at, type: 'date'

      indexes :tags, type: 'object' do
        indexes :name, type: :string
        indexes :id, type: :integer
      end

      indexes :body_types, type: 'object' do
        indexes :name, type: :string
        indexes :id, type: :integer
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

class PersonFacets < ElasticEngine::Search::BaseFacets
  facet_multivalue :tags, 'tags.id', "Tags"
  facet_multivalue_or :body_types, 'body_types.id', "Body Type"

  def faceted_tags(args = {})
    Tag.all.map{|tag| {id: tag.id, term: tag.name} }
  end
  def faceted_body_types(args = {})
    BodyType.all.map{|bt| {id: bt.id, term: bt.name} }
  end
  def default_order
    {
      'created_at' => {order: :desc}
    }
  end
end

class Vehicle < ActiveRecord::Base
  include Searchable
  has_and_belongs_to_many :tags

  # Set up the mapping
  #
  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mapping do
      indexes :id, type: :integer
      indexes :name,      analyzer: 'snowball'
      indexes :created_at, type: 'date'

      indexes :tags, type: 'object' do
        indexes :name, type: :string
        indexes :id, type: :integer
      end
    end
  end

  # Customize the JSON serialization for Elasticsearch
  #
  def as_indexed_json(options={})
    {
      id: id,
      name: name,
      tags: tags.map{ |x| {id: x.id, name: x.name} },
      created_at: created_at
    }
  end
end
class VehicleFacets < ElasticEngine::Search::BaseFacets
  facet_multivalue :tags, 'tags.id', "Tags"

  # def faceted_tags(args = {})
  #   Tag.all.map{|tag| {id: tag.id, term: tag.name} }
  # end
end