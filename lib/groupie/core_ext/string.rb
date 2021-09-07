# frozen_string_literal: true

class Groupie
  module CoreExt
    # This module monkey patches String to respond to #tokenize
    module String
      def tokenize
        warn "Please use Groupie.tokenize instead of String#tokenize (from #{caller(1..1).first})"
        Groupie.tokenize(self)
      end
    end
  end
end

class String
  include Groupie::CoreExt::String
end
