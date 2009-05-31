class Groupie
  class Group
    def initialize(name)
      @name = name
      @word_counts = Hash.new(0)
    end

    # Add new words to the group.
    def add(*words)
      words.flatten.each do |word|
        add_word(word)
      end
      nil
    end

    # Return the count for a specific +word+.
    def count(word)
      @word_counts[word]
    end

    # Add a single word and count it.
    def add_word(word)
      @word_counts[word] += 1
    end
    private :add_word
  end
end