require 'spec_helper'

describe ElasticEngine do
  it "should boot up" do
    ElasticEngine::Configuration.client.should_not be_nil
  end
  it "should prefix the index by default with environment" do
    ElasticEngine::Configuration.index_prefix.should eq('test')
  end
  it "should auto prefix with the applications name" do
    ElasticEngine::Configuration.index_name.should eq('fakeapplication')
  end
  it "should join the index configs to make a index name" do
    ElasticEngine::Configuration.index.should eq('test_fakeapplication')
  end
end
