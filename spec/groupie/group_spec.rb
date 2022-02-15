# frozen_string_literal: true

require 'spec_helper'

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
end
