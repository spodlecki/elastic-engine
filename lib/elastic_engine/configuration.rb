module ElasticEngine
  module Configuration
    extend self
    attr_accessor :client, :index_prefix, :index_name, :url

    def config(&block)
      instance_eval(&block)
    end
    def index
      [index_prefix, index_name].join('_')
    end

    def client
      @client ||= Elasticsearch::Client.new
    end
    def index_prefix
      @index_prefix ||= ::Rails.env
    end
    def index_name
      @index_name ||= ::Rails.application.class.to_s.split("::").first.downcase
    end
  end
end