require 'spec_helper'

describe ElasticEngine::Search::Base do
  before(:all) do
    SeedMaster.apply_database_seeds(10)
    @klass = ElasticEngine::Search::Base.new type: 'person'
  end
  it "should require a type" do
    expect {
      ElasticEngine::Search::Base.new
    }.to raise_error
  end

  describe "new search" do
    before(:each) do
      @search = @klass.search
    end
    it "should return a Response class" do
      @search.class.name.should eq('ElasticEngine::Response::Response')
    end
    it "should have entries" do
      @search.results.count.should eq(Person.count)
    end
    describe "results" do
      before(:each) do
        @results = @search.results
      end
      it "should be a collection" do
        @results.should respond_to(:each)
      end
      it "should be a Result" do
        @results.class.name.should eq('ElasticEngine::Response::Results')
      end
    end
    describe "facets" do
      it "should not explode with no facets set" do
        @search.facets.should be_empty
      end
    end
    describe "query" do
      it "should print out query if requested" do
        @search.query.should be_a(Hash)
      end
    end
  end

  describe "actions" do
    [:filter, :filter_with_execution, :match, :match_all, :order, :paginate].each do |action|
      it "should respond to #{action}" do
        @klass.should respond_to(action)
      end
    end
  end
end
