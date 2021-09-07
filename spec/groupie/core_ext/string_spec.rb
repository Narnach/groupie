# frozen_string_literal: true

require 'spec_helper'

RSpec.describe String do
  describe '#tokenize' do
    it 'splits words' do
      'hello world'.tokenize.should == %w[hello world]
    end

    it 'downcases words' do
      'Hello World'.tokenize.should == %w[hello world]
    end

    it 'strips special characters' do
      'blah, bla!'.tokenize.should == %w[blah bla]
    end

    it 'prserves infix hyphens and underscores' do
      'hyphen-ated under_score'.tokenize.should == %w[hyphen-ated under_score]
    end

    it 'sanitizes html tags' do
      '<a href="http://example.org">example</a>'.tokenize.should == %w[example]
    end

    it 'preserves infix periods' do
      'example.org rocks. read it...'.tokenize.should == %w[example.org rocks read it]
    end

    it 'preserves infix commas' do
      '$1,000,000.00 or $1.000.000,00'.tokenize.should == %w[1,000,000.00 or 1.000.000,00]
    end

    it 'strips quotes around tokens' do
      '"first last"'.tokenize.should == %w[first last]
    end
  end
end
