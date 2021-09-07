# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe Groupie::Group do
  let(:group) { Groupie::Group.new('test') }

  describe '#add' do
    it 'accepts a single string' do
      group.add 'bla'
      group.words.should == %w[bla]
    end

    it 'accepts an Array of strings' do
      group.add %w[bla bla2]
      group.words.should == %w[bla bla2]
    end

    it 'accepts multiple strings' do
      group.add 'bla', 'bla2'
      group.words.should == %w[bla bla2]
    end

    it 'is aliased as <<' do
      group.method(:add).should == group.method(:<<)
    end
  end

  it 'can be serialized and loaded through YAML' do
    group = Groupie::Group.new 'group'
    group.add %w[buy flowers]
    loaded_group = YAML.safe_load(group.to_yaml, permitted_classes: [Groupie::Group])
    loaded_group.add %w[buy candy]
    loaded_group.count('candy').should == 1
  end
end
