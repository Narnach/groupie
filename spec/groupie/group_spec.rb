# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groupie::Group do
  let(:groupie) { Groupie.new }
  let(:group) { Groupie::Group.new('test', groupie) }

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

    it 'increases total_word_count by the number of words' do
      expect do
        group.add(%w[one two three])
      end.to change(group, :total_word_count).from(0).to(3)
    end
  end
end
