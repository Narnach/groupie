# frozen_string_literal: true

require_relative 'groupie/version'
require_relative 'groupie/group'
require_relative 'groupie/core_ext/string'

# Groupie is a text grouper and classifier, using naive Bayesian filtering.
class Groupie
  class Error < StandardError; end

  def initialize
    @groups = {}
  end

  def [](group)
    @groups[group] ||= Group.new(group)
  end

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
        raise "Invalid strategy: #{strategy}"
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
        raise "Invalid strategy: #{strategy}"
      end
      results[name] = count.positive? ? count.to_f / total_count : 0.0
    end

    results
  end

  # Classify a text by taking the average of all word classifications.
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
