class Groupie
  module CoreExt
    module String
      def tokenize
        downcase.gsub(/[^\w -]/,'').split(" ")
      end
    end
  end
end

class String
  include Groupie::CoreExt::String
end