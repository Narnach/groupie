# frozen_string_literal: true

require 'uri'

class Groupie
  # Tokenizer helps turn a String into an Array of Strings that are the
  # individual tokens (mostly words) from the input.
  #
  # Please consider this entire class to be a private API,
  # and use Groupie.tokenize to tokenize things.
  class Tokenizer
    def initialize(input)
      # Ensure our input is converted to a String and duplicated so we can modify it in-place
      @raw = input.to_s.dup
    end

    def to_tokens
      return @tokens if @tokens

      # In-place modifications to our @raw String
      downcase!
      normalize_whitespace!
      strip_html_tags!
      tokenize_urls!
      strip_non_word_characters!

      # Split the resulting string on whitespace and clean up the token candidates
      @tokens = @raw.split.map { |str| remove_interpunction!(str) }

      @tokens
    end

    private

    # Ignore case by downcasing everything
    def downcase!
      @raw.downcase!
    end

    # Convert all types of whitespace (space, tab, newline) into regular spaces
    def normalize_whitespace!
      @raw.gsub!(/\s+/, ' ')
    end

    # Strip HTML tags entirely
    def strip_html_tags!
      @raw.gsub!(/<[^>]+?>/, ' ')
    end

    # Intelligently split URLs into their component parts
    def tokenize_urls!
      @raw.gsub!(%r{http[\w\-\#:/_.?&=]+}) do |url|
        uri = URI.parse(url)
      rescue URI::InvalidURIError
        url
      else
        path = uri.path.to_s
        path.tr!('/_\-', ' ')
        query = uri.query.to_s
        query.tr!('?=&#_\-', ' ')
        fragment = uri.fragment.to_s
        fragment.tr!('#_/\-', ' ')
        "#{uri.scheme} #{uri.host} #{path} #{query} #{fragment}"
      end
    end

    # Strip characters not likely to be part of a word or number
    def strip_non_word_characters!
      @raw.gsub!(/[^\w\ \-.,]/, ' ')
    end

    # Remove wrapping quotes and interpunction from individual token candidates
    def remove_interpunction!(str)
      str.gsub!(/\A['"]+|[!,."']+\Z/, '')
      str
    end
  end
end
