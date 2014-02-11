require 'rubygems'
require 'bundler/setup'

require 'active_support'
require 'active_record'
require 'active_model'

require 'elastic_engine'
require 'elasticsearch/model'

require 'support/searchable'
require 'support/models'
require 'support/seed_master'

require 'elasticsearch/extensions/test/cluster'

module FakeApplication
  class Application
  end
end

ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ":memory:" )
ActiveRecord::LogSubscriber.colorize_logging = false
ActiveRecord::Migration.verbose = false
load "support/schema.rb"

Rails.env = 'test'
Rails.application = FakeApplication::Application.new

ElasticEngine::Configuration.config do |c|
  c.url = "http://localhost:9200"
  c.client = Elasticsearch::Client.new({
    host: c.url,
    retry_on_failure: 5,
    reload_connections: true
  })
end
Elasticsearch::Model.client = ElasticEngine::Configuration.client
RSpec.configure do |config|
  config.before(:suite) do
    if ElasticEngine::Configuration.client.indices.exists index: ElasticEngine::Configuration.index
      ElasticEngine::Configuration.client.indices.delete index: ElasticEngine::Configuration.index
    end

    settings = Person.settings.to_hash
    mappings = Person.mappings.to_hash
    ElasticEngine::Configuration.client.indices.create index: ElasticEngine::Configuration.index,
                                                        body: {
                                                          settings: settings.to_hash,
                                                          mappings: mappings.to_hash }
  end
end