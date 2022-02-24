# frozen_string_literal: true

require_relative 'groupie/version'
require_relative 'groupie/group'
require_relative 'groupie/tokenizer'
require 'set'

# Groupie is a text grouper and classifier, using naive Bayesian filtering.
class Groupie
  # Wrap all errors we raise in this so our own errors are recognizable.
  class Error < StandardError; end

  attr_accessor :smart_weight

  # @param [true, false] smart_weight (false) Whether smart weight is enabled or not.
  def initialize(smart_weight: false)
    @groups = {}
    @smart_weight = smart_weight
    @known_words = Set.new
  end

  # Turn a String (or anything else that responds to #to_s) into an Array of String tokens.
  # This attempts to remove most common punctuation marks and types of whitespace.
  #
  # @param [String, #to_s] object
  # @return [Array<String>]
  def self.tokenize(object)
    Tokenizer.new(object).to_tokens
  end

  # Access an existing Group or create a new one.
  #
  # @param [Object] group The name of the group to access.
  # @return [Groupie::Group] An existing or new group identified by +group+.
  def [](group)
    @groups[group] ||= Group.new(group, self)
  end

  # Classify a text by taking the average of all word classifications.
  #
  # @param [Array<String>] words List of words to be classified
  # @param [Symbol] strategy
  # @return [Hash<Object, Float>] Hash with <group, score> pairings. Scores are always in 0.0..1.0
  # @raise [Groupie::Error] Raise when an invalid strategy is provided
  def classify_text(words, strategy = :sum)
    words &= unique_words if strategy == :unique
    group_score_sums, hits = calculate_group_scores(words, strategy)

    group_score_sums.each.with_object({}) do |(group, sum), averages|
      averages[group] = hits.positive? ? sum / hits : 0
    end
  end

  # Classify a single word against all groups, returning the probability distribution.
  #
  # @param [String] entry A word to be classified
  # @param [Symbol] strategy (:sum) the strategy to use on the score
  # @return [Hash<Object, Float>] Hash with <group, probability> pairings.
  #   Probabilities are always in 0.0..1.0, and add up to 1.0 (i.e. it's a probability distribution)
  # @raise [Groupie::Error] Raise when an invalid strategy is provided
  def classify(entry, strategy = :sum)
    # Calculate default weight once outside of the loop
    default_weight = self.default_weight
    # Each group calculates the count, then reduces it to a score: <group name, score>
    per_group_score = @groups.transform_values do |group|
      apply_count_strategy(default_weight + group.count(entry), strategy)
    end
    # When we have no scores, we have no results, so abort early
    # Note that when smart_weight is enabled we always have a score.
    total_score = per_group_score.values.sum
    return {} if total_score.zero?

    # Final results must be within 0.0..1.0, so divide each score by the total score
    per_group_score.transform_values { |group_score| group_score.to_f / total_score }
  end

  # Return a word score dictionary that excludes the 4th quartile most popular words.
  # Why do this? So the most common (and thus meaningless) words are ignored
  # and less common words gain more predictive power.
  #
  # This is used by the :unique strategy of the classifier.
  #
  # @return [Hash<String, Integer>]
  def unique_words
    # Iterate over all Groups and merge their <word, count> dictionaries into one
    total_count = @groups.inject({}) do |total, (_name, group)|
      total.merge!(group.word_counts) { |_key, o, n| o + n }
    end
    # Extract the word count that's at the top 75%
    top_quartile_index = [((total_count.size * 3) / 4) - 1, 1].max
    top_quartile_frequency = total_count.values.sort[top_quartile_index]
    # Throw out all words which have a count that's above this frequency
    total_count.reject! { |_word, count| count > top_quartile_frequency }
    total_count.keys
  end

  # Default weight is used when +smart_weight+ is enabled.
  # Each word's count is increased by the +default_weight+ value,
  # which is the average frequency of each unique word we know about.
  #
  # Example: if we have indexed 1000 total words, of which 500 were unique,
  #   the default_weight would be 1000/500=2.0
  #
  # @return [Float] The default weight for all words
  def default_weight
    # Default weight only applies when smart weight is enabled
    return 0.0 unless smart_weight

    # If we don't know any words, the weight is also zero
    return 0.0 unless @known_words.any?

    # Gather counts and calculate
    total_words = @groups.each_value.sum(&:total_word_count)
    total_unique_words = @known_words.count
    total_words / total_unique_words.to_f
  end

  # Private method used by Groups to register known words with the Group.
  def add_word(word)
    @known_words << word
  end

  private

  # Calculate grouped scores
  #
  # @param [Array<String>] words
  # @param [Symbol] strategy
  # @return [Array<Enumerator<String>, Integer>] a Hash with <group, score> pairs and an integer with the number of hits
  def calculate_group_scores(words, strategy)
    hits = 0
    group_score_sums = words.each.with_object({}) do |word, results|
      word_results = classify(word, strategy)
      next results if word_results.empty?

      hits += 1
      results.merge!(word_results) { |_key, old, new| old + new }
    end

    [group_score_sums, hits]
  end

  # Helper function to reduce a raw word count to a strategy-modified weight.
  # @param [Integer] count
  # @param [Symbol] strategy
  # @return [Integer, Float]
  # @raise [Groupie::Error] Raise when an invalid strategy is provided
  def apply_count_strategy(count, strategy)
    case strategy
    when :sum
      # keep count
    when :sqrt, :unique
      count = Math.sqrt(count)
    when :log
      count = Math.log10(count) if count.positive?
    else
      raise Error, "Invalid strategy: #{strategy}"
    end
    count
  end
end
