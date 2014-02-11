class SeedMaster
  def self.apply_database_seeds(count=1)
    Person.all.each{|x| x.destroy }
    Tag.all.each{|x| x.destroy }
    BodyType.all.each{|x| x.destroy }
    
    count.times do |n|
      Person.create!({
        name: "Jimmy ##{n}"
      })
    end
    5.times do |n|
      Tag.create!({
        name: "Tag#{n}"
      })
      BodyType.create!({
        name: "BodyType#{n}"
      })
    end

    Person.limit(10).each do |p|
      p.tags = Tag.limit((1..6).to_a.sample).all
      p.body_types = BodyType.limit((1..2).to_a.sample).all
      p.save!
    end

    ElasticEngine::Configuration.client.indices.refresh
  end
end