require File.join(File.dirname(__FILE__), %w[.. .. test_helper])

Testy.testing 'String' do
  context 'tokenize' do
    test 'split words' do |t|
      tokens = "hello world".tokenize
      t.check 'words are split',
        :expect => %w[hello world],
        :actual => tokens
    end
    
    test 'downcase words' do |t|
      tokens = "Hello World".tokenize
      t.check 'words are downcased',
        :expect => %w[hello world],
        :actual => tokens
    end
    
    test 'most symbols are stripped' do |t|
      tokens = "hyphen-ated, under_score!".tokenize
      t.check 'some symbols are left',
        :expect => %w[hyphen-ated under_score],
        :actual => tokens
    end
  end
end
