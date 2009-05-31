class Groupie
  class Group
    def initialize(name)
      @name = name
      @word_counts = {}
    end
    
    def words
      @word_counts.keys
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
      @word_counts[word] || 0
    end

    # Add a single word and count it.
    def add_word(word)
      @word_counts[word] ||= 0
      @word_counts[word] += 1
    end
    private :add_word
  end
end