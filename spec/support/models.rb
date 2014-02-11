class BodyType < ActiveRecord::Base
  has_and_belongs_to_many :people
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :people
end

class Person < ActiveRecord::Base
  include Searchable
  has_and_belongs_to_many :body_types
  has_and_belongs_to_many :tags
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

  # def default_filter
  #   ret = Array.new
  #   ret << { :type => { :value => 'banner' } }
  #   ret << { :term => { :published => true } }
  #   ret
  # end
  def default_order
    {
      'created_at' => {order: :desc}
    }
  end
end