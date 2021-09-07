# frozen_string_literal: true

require_relative 'groupie/version'
require_relative 'groupie/group'
require_relative 'groupie/core_ext/string'

# Groupie is a text grouper and classifier, using naive Bayesian filtering.
class Groupie
  # Wrap all errors we raise in this so our own errors are recognizable.
  class Error < StandardError; end

  def initialize
    @groups = {}
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
    @groups[group] ||= Group.new(group)
  end

  # Return a word score dictionary that excludes the 4th quartile most popular words.
  # Why do this? So the most common (and thus meaningless) words are ignored
  # and less common words gain more predictive power.
  #
  # This is used by the :unique strategy of the classifier.
  #
  # @return [Hash<String, Integer>]
  def unique_words
    @unique_words ||= begin
      total_count = @groups.values.map(&:word_counts).inject do |total, counts|
        total.merge(counts) do |_key, o, n|
          o + n
        end
      end
      median_index = [total_count.values.size * 3 / 4 - 1, 1].max
      median_frequency = total_count.values.sort[median_index]
      total_count.select { |_word, count| count <= median_frequency }.map(&:first)
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
    total_count = @groups.inject(0) do |sum, name_group|
      group = name_group.last
      count = group.count(entry)
      case strategy
      when :sum
        sum += count
      when :sqrt, :unique
        sum += Math.sqrt(count)
      when :log
        sum += Math.log10(count) if count.positive?
      else
        raise Error, "Invalid strategy: #{strategy}"
      end
      next sum
    end
    return results if total_count.zero?

    @groups.each do |name, group|
      count = group.count(entry)
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
      results[name] = count.positive? ? count.to_f / total_count : 0.0
    end

    results
  end

  # Classify a text by taking the average of all word classifications.
  #
  # @param [Array<String>] words List of words to be classified
  # @param [Symbol] strategy
  # @return [Hash<Object, Float>] Hash with <group, score> pairings. Scores are always in 0.0..1.0
  # @raise [Groupie::Error] Raise when an invalid strategy is provided
  def classify_text(words, strategy = :sum)
    hits = 0
    words &= unique_words if strategy == :unique
    group_score_sums = words.inject({}) do |results, word|
      word_results = classify(word, strategy)
      next results if word_results.empty?

      hits += 1
      results.merge(word_results) do |_key, old, new|
        old + new
      end
    end

    averages = {}
    group_score_sums.each do |group, sum|
      averages[group] = hits.positive? ? sum / hits : 0
    end

    averages
  end
end
