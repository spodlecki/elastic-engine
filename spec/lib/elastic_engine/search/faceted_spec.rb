require 'spec_helper'

describe ElasticEngine::Search::Faceted do
  before(:all) do
    SeedMaster.apply_database_seeds(10)
  end
  describe "basic results" do
    before(:each) do
      @klass = ElasticEngine::Search::Faceted.new type: 'person'
    end
    describe "basic results with facets" do
      before(:each) do
        @result = @klass.search
      end
      it "should have many facets" do
        @result.facets.count.should eq(2)
      end
      describe "facet attributes" do
        before(:each) do
          @facet_group = @result.facets.first
        end
        it "should have many terms" do
          @facet_group.terms.count.should eq(Tag.count)
        end
        it "should set a key as a symbol" do
          @facet_group.key.should be_a(Symbol)
        end
        it "should have a hash for result_terms" do
          @facet_group.result_terms.should be_a(Hash)
        end
        describe "terms" do
          it "should have a count" do
            @facet_group.terms.first.should respond_to(:count)
          end
          it "should have a name" do
            @facet_group.terms.first.should respond_to(:name)
          end
          it "should have an id" do
            @facet_group.terms.first.should respond_to(:id)
          end
          it "should have the right count" do
            term = @facet_group.terms.sample
            tag_id = term.id
            count = Tag.find(tag_id).people.count
            term.count.should eq(count)
          end
        end
      end
    end
  end
end
