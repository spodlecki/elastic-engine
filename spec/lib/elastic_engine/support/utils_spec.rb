require 'spec_helper'

describe ElasticEngine::Support::Utils do
  before(:each) do
    @klass = ElasticEngine::Support::Utils
  end
  describe "__validate_selection_with_raise" do
    describe "valid attributes" do
      it "should not raise an error" do
        expect {
          __operator = :and
          @klass.__validate_selection_with_raise(__operator.to_sym, [:and, :or])
        }.to_not raise_error
      end
    end
    describe "invalid attribute" do
      it "should raise an ArgumentError" do
        expect {
          __operator = :bool
          @klass.__validate_selection_with_raise(__operator.to_sym, [:and, :or])
        }.to raise_error(ArgumentError)
      end
    end
  end
  describe "__validate_integer" do
    describe "valid attribute" do
      (0..15).each do |n|
        it "should allow #{n} as #{n.class.to_s}" do
          @klass.__validate_integer(n).should eq(n)
        end
      end
      it "should allow a string int if its invalid" do
        @klass.__validate_integer("15").should eq(15)
      end
      it "should allow a neg number as a string if allowed" do
        @klass.__validate_integer("-1", 0, false).should eq(-1)
      end
      it "should allow a neg number as a int if allowed" do
        @klass.__validate_integer(-1, 0, false).should eq(-1)
      end
    end
  end
  describe "invalid attribute" do
    it "should revert to default if its invalid int" do
      @klass.__validate_integer(-1).should eq(0)
    end
    it "should set a new default" do
      @klass.__validate_integer(-1, 10).should eq(10)
    end
  end
end
