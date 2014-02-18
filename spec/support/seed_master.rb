class SeedMaster
  def self.apply_database_seeds(count=1)
    models = [Vehicle,Person]
    models.each do |klass|
      ElasticEngine::Configuration.client.indices.put_mapping(index: ElasticEngine::Configuration.index, type: klass.name.to_s.downcase, body: klass.mappings.to_hash)
    end

    Vehicle.all.each{|x| x.destroy }
    Person.all.each{|x| x.destroy }
    Tag.all.each{|x| x.destroy }
    BodyType.all.each{|x| x.destroy }
    
    count.times do |n|
      Person.create!({
        name: "Jimmy ##{n}"
      })
      Vehicle.create!({
        name: "Vehicle ##{n}"
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
    Vehicle.limit(10).each do |v|
      v.tags = Tag.limit((1..6).to_a.sample).all
      v.save!
    end
    ElasticEngine::Configuration.client.indices.refresh
  end
end