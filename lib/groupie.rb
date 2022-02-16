# frozen_string_literal: true

require_relative 'groupie/version'
require_relative 'groupie/group'
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
  end

  # Turn a String (or anything else that responds to #to_s) into an Array of String tokens.
  # This attempts to remove most common punctuation marks and types of whitespace.
  #
  # @param [String, #to_s] object
  # @return [Array<String>]
  def self.tokenize(object)
    object
      .to_s
      .downcase
      .gsub(/\s/, ' ')
      .gsub(/[$']/, '')
      .gsub(/<[^>]+?>|[^\w -.,]/, '')
      .split.map { |str| str.gsub(/\A['"]+|[!,."']+\Z/, '') }
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

  # Classify a single word against all groups.
  #
  # @param [String] entry A word to be classified
  # @param [Symbol] strategy
  # @return [Hash<Object, Float>] Hash with <group, score> pairings. Scores are always in 0.0..1.0
  # @raise [Groupie::Error] Raise when an invalid strategy is provided
  def classify(entry, strategy = :sum)
    results = {}
    default_weight = self.default_weight
    total_count = @groups.values.inject(0) do |sum, group|
      sum + apply_count_strategy(default_weight + group.count(entry), strategy)
    end
    return results if total_count.zero?

    @groups.each do |name, group|
      count = apply_count_strategy(default_weight + group.count(entry), strategy)
      results[name] = count.positive? ? count.to_f / total_count : 0.0
    end

    results
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
    return 0.0 unless smart_weight

    # Find all unique words and the total count of all words
    total_words = 0
    unique_words = Set.new
    @groups.each_value do |group|
      unique_words += group.words
      total_words += group.total_word_count
    end
    total_unique_words = unique_words.count
    return 0.0 unless total_unique_words.positive?

    total_words / total_unique_words.to_f
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
