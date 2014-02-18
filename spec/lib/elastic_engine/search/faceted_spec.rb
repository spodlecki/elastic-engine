require 'spec_helper'

describe ElasticEngine::Search::Faceted do
  before(:all) do
    SeedMaster.apply_database_seeds(10)
  end
  describe "without faceted config options" do
    ['|',','].each do |operator_type|
      describe "results with #{operator_type} params" do
        before(:each) do
          @tags = Tag.select('DISTINCT tags.*').joins(:vehicles).limit(2)
          params = {
            tags: @tags.collect(&:id).join(operator_type)
          }
          @klass = ElasticEngine::Search::Faceted.new type: 'vehicle', params: params
        end
        describe "faceted results" do
          before(:each) do
            @result = @klass.search
          end
          it "should have the single facet" do
            @result.facets.count.should eq(1)
          end
          describe "facet_group" do
            before(:each) do
              @facet_group = @result.facets.first
              @facet_group.key.should eq(:tags)
            end
            it "should build a pill with text from elasticsearch" do
              @tags.collect(&:id).each do |id|
                @facet_group.pill_text.should  =~ /#{id}/
              end
              @facet_group.pill_text.should  =~ /#{operator_type == '|' ? 'OR' : 'AND'}/
            end
            describe "group_param_values" do
              it "should return an array" do
                @facet_group.group_param_values.should be_a(Array)
              end
              it "should match a group of ids" do
                @tags.collect(&:id).map(&:to_s).should eq(@facet_group.group_param_values)
              end
            end
          end
        end
      end
    end
  end
  describe "with faceted config" do
    ['|',','].each do |operator_type|
      describe "results with #{operator_type} params" do
        before(:each) do
          @tags = Tag.select('DISTINCT tags.*').limit(4)
          params = {
            tags: @tags.collect(&:id).join(operator_type)
          }
          @klass = ElasticEngine::Search::Faceted.new type: 'person', params: params
        end
        describe "faceted results" do
          before(:each) do
            @result = @klass.search
          end
          it "should have many facets" do
            @result.facets.count.should eq(2)
          end
          describe "facet_group" do
            before(:each) do
              @facet_group = @result.facets.first
              @facet_group.key.should eq(:tags)
            end
            it "should build a pill with text from database" do
              @tags.collect(&:name).each do |name|
                @facet_group.pill_text.should  =~ /#{name}/
              end
              @facet_group.pill_text.should  =~ /#{operator_type == '|' ? 'OR' : 'AND'}/
            end
            describe "group_param_values" do
              it "should return an array" do
                @facet_group.group_param_values.should be_a(Array)
              end
              it "should match a group of ids" do
                @tags.collect(&:id).map(&:to_s).should eq(@facet_group.group_param_values)
              end
            end
          end
        end
      end
    end
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
