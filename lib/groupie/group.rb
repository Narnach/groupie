# frozen_string_literal: true

class Groupie
  # Group represents a group or category that words can be classified into.
  class Group
    attr_reader :word_counts, :total_word_count

    def initialize(name, groupie)
      @name = name
      @groupie = groupie
      @word_counts = {}
      @total_word_count = 0
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

    alias << add

    # Return the count for a specific +word+.
    def count(word)
      @word_counts[word] || 0
    end

    private

    # Add a single word and count it.
    def add_word(word)
      @word_counts[word] ||= 0
      @word_counts[word] += 1
      @total_word_count += 1
    end
  end
end
