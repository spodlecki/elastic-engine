require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'active_model'

require 'elastic_engine'
require 'elasticsearch/extensions/test/cluster'

module FakeApplication
  class Application
  end
end

Rails.env = 'test'
Rails.application = FakeApplication::Application.new

RSpec.configure do |config|
  config.before(:suite) do
    setup
  end
  config.after(:suite) do
    # Elasticsearch::Extensions::Test::Cluster.stop
  end
end

def setup
  ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ":memory:" )
  logger = ::Logger.new(STDERR)
  logger.formatter = lambda { |s, d, p, m| "#{m.ansi(:faint, :cyan)}\n" }
  ActiveRecord::Base.logger = logger unless ENV['QUIET']

  ActiveRecord::LogSubscriber.colorize_logging = false
  ActiveRecord::Migration.verbose = false

  tracer = ::Logger.new(STDERR)
  tracer.formatter = lambda { |s, d, p, m| "#{m.gsub(/^.*$/) { |n| '   ' + n }.ansi(:faint)}\n" }
  ElasticEngine::Configuration.config do |c|
    c.client = Elasticsearch::Client.new host: "localhost:#{(ENV['TEST_CLUSTER_PORT'] || 9250)}", tracer: (ENV['QUIET'] ? nil : tracer)
  end
end