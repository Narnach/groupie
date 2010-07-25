require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'yaml'

describe Groupie::Group do
  it "can be serialized and loaded through YAML" do
    group = Groupie::Group.new 'group'
    group.add %w[buy flowers]
    loaded_group = YAML.load(group.to_yaml)
    loaded_group.add %w[buy candy]
    loaded_group.count("candy").should == 1
  end
end
