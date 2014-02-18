ActiveRecord::Schema.define(version: 1) do
  create_table :vehicles do |t|
    t.string     :name
    t.timestamps
  end
  create_table :tags_vehicles do |t|
    t.integer  :vehicle_id
    t.integer :tag_id
  end

  create_table :people do |t|
    t.string     :name
    t.timestamps
  end
  create_table :people_tags do |t|
    t.integer  :person_id
    t.integer :tag_id
  end
  create_table :tags do |t|
    t.string  :name
    t.timestamps
  end

  create_table :body_types_people do |t|
    t.integer  :person_id
    t.integer :body_type_id
  end
  create_table :body_types do |t|
    t.string  :name
    t.timestamps
  end
end