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

    test 'html tags are sanitized' do |t|
      tokens = '<a href="http://example.org">example</a>'.tokenize
      t.check 'only content of tags is retained',
        :expect => %w[example],
        :actual => tokens
    end

    test 'some dots are ok' do |t|
      tokens = 'example.org rocks. read it...'.tokenize
      t.check 'infix dots are kept',
        :expect => %w[example.org rocks read it],
        :actual => tokens

      tokens2 = '$1,000,000.00 or $1.000.000,00'.tokenize
      t.check 'infix commas are kept',
        :expect => %w[1,000,000.00 or 1.000.000,00],
        :actual => tokens2
    end
  end
end
