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

      # Ignore case by downcasing everything
      @raw.downcase!
      # Convert all types of whitespace (space, tab, newline) into regular spaces
      @raw.gsub!(/\s+/, ' ')
      # Strip HTML tags entirely
      @raw.gsub!(/<[^>]+?>/, ' ')
      # Intelligently split URLs into their component parts
      @raw.gsub!(%r{http[\w\-\#:/_.?&=]+}) do |url|
        uri = URI.parse(url)
        path = uri.path.to_s
        path.tr!('/_\-', ' ')
        query = uri.query.to_s
        query.tr!('?=&#_\-', ' ')
        fragment = uri.fragment.to_s
        fragment.tr!('#_/\-', ' ')
        "#{uri.scheme} #{uri.host} #{path} #{query} #{fragment}"
      end
      # Strip characters not likely to be part of a word or number
      @raw.gsub!(/[^\w\ \-.,]/, ' ')
      # Split the resulting string on whitespace
      @tokens = @raw.split.map do |str|
        # Final cleanup of wrapped quotes and interpunction
        str.gsub!(/\A['"]+|[!,."']+\Z/, '')
        str
      end

      @tokens
    end
  end
end
