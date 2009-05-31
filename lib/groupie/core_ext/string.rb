class Groupie
  module CoreExt
    module String
      def tokenize
        downcase.
          gsub(/\s/," ").
          gsub(/[$']/,'').
          gsub(/<[^>]+?>|[^\w -.,]/,'').
          split(" ").map {|str| str.gsub(/[,.]+\Z/,'')}
      end
    end
  end
end

class String
  include Groupie::CoreExt::String
end