require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'yaml'

describe Groupie::Group do
  describe "add" do
    before(:each) do
      @group = Groupie::Group.new("test")
    end

    it "should accept a single string" do
      @group.add "bla"
      @group.words.should == %w[bla]
    end

    it "should accept an Array of strings" do
      @group.add ["bla", "bla2"]
      @group.words.should == %w[bla bla2]
    end

    it "should accept multiple strings" do
      @group.add "bla", "bla2"
      @group.words.should == %w[bla bla2]
    end

    it "should be aliased as <<" do
      @group.method(:add).should == @group.method(:<<)
    end
  end

  it "can be serialized and loaded through YAML" do
    group = Groupie::Group.new 'group'
    group.add %w[buy flowers]
    loaded_group = YAML.load(group.to_yaml)
    loaded_group.add %w[buy candy]
    loaded_group.count("candy").should == 1
  end
end
