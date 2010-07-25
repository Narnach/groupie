require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe String do
  context "tokenize" do
    it 'should split words' do
      "hello world".tokenize.should == %w[hello world]
    end

    it 'should downcase words' do
      "Hello World".tokenize.should == %w[hello world]
    end

    it 'should strip special characters' do
      "blah, bla!".tokenize.should == %w[blah bla]
    end

    it 'should prserve infix hyphens and underscores' do
      "hyphen-ated under_score".tokenize.should == %w[hyphen-ated under_score]
    end

    it 'should sanitize html tags' do
      '<a href="http://example.org">example</a>'.tokenize.should == %w[example]
    end

    it 'should preserve infix periods' do
      'example.org rocks. read it...'.tokenize.should == %w[example.org rocks read it]
    end
    
    it "should preserve infix commas" do
      '$1,000,000.00 or $1.000.000,00'.tokenize.should == %w[1,000,000.00 or 1.000.000,00]
    end
  end
end
