# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groupie do
  it 'has a version' do
    Groupie.version.should_not be_nil
  end

  describe '#classify' do
    it 'works when 100% certain' do
      g = Groupie.new
      g[:spam].add %w[viagra]
      g[:ham].add %w[flowers]
      g.classify('viagra').should eq({ spam: 1.0, ham: 0.0 })
    end

    it 'works when split 50/50 between two groups' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:ham].add %w[buy flowers for your mom]
      g.classify('buy').should eq({ spam: 0.5, ham: 0.5 })
    end

    it 'works when weighed more towards one group' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:spam].add %w[buy cialis now]
      g[:ham].add %w[buy flowers for your mom]
      g.classify('buy').should eq({ spam: 2 / 3.0, ham: 1 / 3.0 })
    end

    it 'works with more than two groups' do
      g = Groupie.new
      g[:weight].add 'pound'
      g[:currency].add 'pound'
      g[:phone_key].add 'pound'
      g.classify('pound').should eq({ weight: 1 / 3.0, currency: 1 / 3.0, phone_key: 1 / 3.0 })
    end

    it 'tokenizes and classify emails' do
      email = File.read(File.join(File.dirname(__FILE__), %w[fixtures spam email_spam1.txt]))
      email2 = File.read(File.join(File.dirname(__FILE__), %w[fixtures spam email_spam2.txt]))
      email3 = File.read(File.join(File.dirname(__FILE__), %w[fixtures ham email_ham1.txt]))
      g = Groupie.new
      g[:spam].add email.tokenize
      g[:spam].add email2.tokenize
      g[:ham].add email3.tokenize
      c = g.classify('discreetly')
      c[:spam].should > c[:ham]
      c2 = g.classify('user')
      c2[:ham].should > c2[:spam]
    end

    describe 'strategies' do
      describe 'sum' do
        it 'weighs words for the sum of their occurrences' do
          g = Groupie.new
          g[:spam].add %w[word] * 9
          g[:ham].add %w[word]
          g.classify('word', :sum).should eq({ spam: 0.9, ham: 0.1 })
        end
      end

      describe 'sqrt' do
        it 'weighs words for the square root of the sum of occurrences' do
          g = Groupie.new
          g[:spam].add %w[word] * 9
          g[:ham].add %w[word]
          g.classify('word', :sqrt).should eq({ spam: 0.75, ham: 0.25 })
        end
      end

      describe 'log' do
        it 'weighs words for log10 of their sum of occurrences' do
          g = Groupie.new
          g[:spam].add %w[word] * 1000
          g[:ham].add %w[word] * 10
          g.classify('word', :log).should eq({ spam: 0.75, ham: 0.25 })
        end
      end

      describe 'unique' do
        it 'shoulds behave as sqrt strategy' do
          g = Groupie.new
          g[:spam].add %w[buy viagra now]
          g[:ham].add %w[buy flowers now]
          g.classify('buy', :unique).should eq(g.classify('buy', :sqrt))
          g.classify('flowers', :unique).should eq(g.classify('flowers', :sqrt))
        end
      end

      it 'raises an error when a nonexistant strategy is given' do
        g = Groupie.new
        g[:test].add %w[test]
        expect do
          g.classify('test', :imaginary)
        end.to raise_error(Groupie::Error, 'Invalid strategy: imaginary')
      end
    end
  end

  describe '#unique_words' do
    it 'excludes all words in the 4th quantiles of all groups' do
      g = Groupie.new
      g[:spam].add %w[one two two three three three four four four four]
      g[:ham].add %w[apple banana pear orange three]
      g.unique_words.sort.should eq(%w[one two apple banana pear orange].sort)
    end

    it 'works on an empty word set' do
      g = Groupie.new
      g[:spam].add []
      g[:ham].add []
      g.unique_words.should eq([])
    end
  end

  describe '#classify_text' do
    it 'tokenizes html emails' do
      g = Groupie.new
      spam_tokens = File.read(File.join(File.dirname(__FILE__), %w[fixtures spam spam.la-44118014.txt])).tokenize
      ham_tokens = File.read(File.join(File.dirname(__FILE__), %w[fixtures ham spam.la-44116217.txt])).tokenize
      g[:spam].add spam_tokens
      g[:ham].add ham_tokens

      c = g.classify 'user'
      c[:ham].should > c[:spam]

      c = g.classify_text(spam_tokens)
      c[:spam].should > c[:ham]
    end

    it 'classifies a text' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now to grow fast]
      g[:spam].add %w[buy cialis on our website]
      g[:ham].add %w[buy flowers for your mom]
      result = g.classify_text 'Grow flowers to sell on our website'.tokenize
      result[:spam].should > result[:ham]
      result2 = g.classify_text 'Grow flowers to give to your mom'.tokenize
      result2[:ham].should eq(result2[:spam])
    end

    it 'skips unknown tokens' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:ham].add %w[buy flowers now]
      g.classify_text(%w[buy buckets now]).should eq({ spam: 0.5, ham: 0.5 })
    end

    it 'supports the sqrt strategy' do
      g = Groupie.new
      g[:spam].add %w[one] * 9
      g[:ham].add %w[one]
      g[:spam].add %w[two] * 9
      g[:ham].add %w[two]
      g.classify_text(%w[one two three], :sqrt).should eq({ spam: 0.75, ham: 0.25 })
    end

    it 'supports the log strategy' do
      g = Groupie.new
      g[:spam].add %w[one] * 100
      g[:ham].add %w[one]
      g[:spam].add %w[two]
      g[:ham].add %w[two] * 100
      g.classify_text(%w[one two three], :log).should eq({ spam: 0.5, ham: 0.5 })
    end

    it 'only rates unique words for the unique strategy' do
      g = Groupie.new
      g[:spam].add %w[one two two three three three four four four four]
      g[:ham].add %w[apple banana pear]
      g.classify_text(%w[one two three apple banana], :unique).should eq({ spam: 0.5, ham: 0.5 })
    end

    it 'raises an error when a nonexistant strategy is given' do
      g = Groupie.new
      g[:test].add %w[test]
      expect do
        g.classify_text(%w[test], :imaginary)
      end.to raise_error(Groupie::Error, 'Invalid strategy: imaginary')
    end
  end
end
