class BodyType < ActiveRecord::Base
  belongs_to :person
end

class Tag < ActiveRecord::Base
  belongs_to :Person
end

class Person < ActiveRecord::Base
  has_one                 :body_type
  has_many                :tags
end

Person.__send__ :include, Searchable