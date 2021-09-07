# frozen_string_literal: true

class Groupie
  module CoreExt
    # This module monkey patches String to respond to #tokenize
    module String
      def tokenize
        downcase
          .gsub(/\s/, ' ')
          .gsub(/[$']/, '')
          .gsub(/<[^>]+?>|[^\w -.,]/, '')
          .split.map { |str| str.gsub(/\A['"]+|[!,."']+\Z/, '') }
      end
    end
  end
end

class String
  include Groupie::CoreExt::String
end
