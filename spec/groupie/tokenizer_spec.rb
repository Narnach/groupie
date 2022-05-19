# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groupie::Tokenizer do
  describe '#to_tokens' do
    let(:input) { 'this is a test' }
    let(:tokenizer) { Groupie::Tokenizer.new(input) }
    let(:result) { tokenizer.to_tokens }

    it 'returns the same object when called twice' do
      first_call = tokenizer.to_tokens
      second_call = tokenizer.to_tokens
      expect(first_call).to be(second_call)
    end

    describe 'given multiple words' do
      it 'splits words' do
        expect(result).to eq(%w[this is a test])
      end
    end

    describe 'given mixed case words' do
      let(:input) { 'Hello World' }

      it 'downcases words' do
        expect(result).to eq(%w[hello world])
      end
    end

    describe 'given a sentence with puncuation' do
      let(:input) { 'Blah, bla! This is nice.' }

      it 'strips punctuation' do
        expect(result).to eq(%w[blah bla this is nice])
      end
    end

    describe 'given words with infix hyphens and underscores' do
      let(:input) { 'hyphen-ated under_score' }

      it 'preserves infix hyphens and underscores' do
        expect(result).to eq(%w[hyphen-ated under_score])
      end
    end

    describe 'given HTML tags' do
      let(:input) { '<a href="http://example.org">example</a>' }

      it 'preserves only the text content' do
        expect(result).to eq(%w[example])
      end
    end

    describe 'given words with infix periods' do
      let(:input) { 'example.org rocks. read it...' }

      it 'preserves infix periods' do
        expect(result).to eq(%w[example.org rocks read it])
      end
    end

    describe 'given numbers with infix periods and commas' do
      let(:input) { '$1,000,000.00 or $1.000.000,00' }

      it 'preserves infix periods and commas' do
        expect(result).to eq(%w[1,000,000.00 or 1.000.000,00])
      end
    end

    describe 'given quoted tokens' do
      let(:input) { '"first last"' }

      it 'strips the quotes' do
        expect(result).to eq(%w[first last])
      end
    end

    describe 'given a full URL' do
      let(:input) { 'https://example.org/blog-path/2022/1234-title-of-blog-post?custom=query&foo=bar#my-anchor' }

      it 'extracts each segment as a token' do
        expect(result).to eq(
          %w[https example.org blog path 2022 1234 title of blog post custom query foo bar my anchor]
        )
      end
    end

    describe 'given a minimal URL without path' do
      let(:input) { 'https://example.org' }

      it 'extracts the tokens available' do
        expect(result).to eq(%w[https example.org])
      end
    end

    describe 'given an invalid URL' do
      let(:input) { 'http://example.org:3000&amp' }

      it 'extracts tokens as if it were plain text' do
        expect(result).to eq(%w[http example.org 3000 amp])
      end
    end
  end
end
