require File.join(File.dirname(__FILE__), 'spec_helper')

describe Groupie do
  describe "classify" do
    it 'should work when 100% certaint' do
      g = Groupie.new
      g[:spam].add %w[viagra]
      g[:ham].add %w[flowers]
      g.classify('viagra').should == {:spam => 1.0, :ham => 0.0}
    end

    it 'should work when split 50/50 between two groups' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:ham].add %w[buy flowers for your mom]
      g.classify('buy').should == {:spam => 0.5, :ham => 0.5}
    end

    it 'should work when weighed more towards one group' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:spam].add %w[buy cialis now]
      g[:ham].add %w[buy flowers for your mom]
      g.classify('buy').should == {:spam => 2 / 3.0, :ham => 1 / 3.0}
    end

    it 'should work with more than two groups' do
      g = Groupie.new
      g[:weight].add 'pound'
      g[:currency].add 'pound'
      g[:phone_key].add 'pound'
      g.classify('pound').should == {:weight => 1/3.0, :currency => 1/3.0, :phone_key => 1/3.0}
    end

    it 'should tokenize and classify emails' do
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
  end

  context "classify_text" do
    it 'should tokenized html emails' do
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

    it 'should classify a text' do
      g = Groupie.new
      g[:spam].add %w[buy viagra now to grow fast]
      g[:spam].add %w[buy cialis on our website]
      g[:ham].add %w[buy flowers for your mom]
      result = g.classify_text "Grow flowers to sell on our website".tokenize
      result[:spam].should > result[:ham]
      result2 = g.classify_text "Grow flowers to give to your mom".tokenize
      result2[:ham].should == result2[:spam]
    end

    it "should skip unknown tokens" do
      g = Groupie.new
      g[:spam].add %w[buy viagra now]
      g[:ham].add %w[buy flowers now]
      g.classify_text(%w[buy buckets now]).should == {:spam=>0.5, :ham=>0.5}
    end
  end
end
