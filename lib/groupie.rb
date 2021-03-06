lib_dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'groupie/group'
require 'groupie/core_ext/string'

class Groupie
  def initialize
    @groups = {}
  end

  def [](group)
    @groups[group] ||= Group.new(group)
  end

  def unique_words
    @unique_words ||= (
      total_count = @groups.values.map {|group| group.word_counts}.inject{|total, counts| total.merge(counts){|key,o,n| o+n}}
      median_index = [total_count.values.size * 3 / 4 - 1, 1].max
      median_frequency = total_count.values.sort[median_index]
      total_count.select{|word, count| count <= median_frequency}.map(&:first)
    )
  end

  def classify(entry, strategy=:sum)
    results = {}
    total_count = @groups.inject(0) do |sum, name_group|
      group = name_group.last
      count = group.count(entry)
      case strategy
      when :sum
        sum += count
      when :sqrt, :unique
        sum += Math::sqrt(count)
      when :log
        sum += Math::log10(count) if count > 0
      else
        raise "Invalid strategy: #{strategy}"
      end
      next sum
    end
    return results if 0 == total_count

    @groups.each do |name, group|
      count = group.count(entry)
      case strategy
      when :sum
        # keep count
      when :sqrt, :unique
        count = Math::sqrt(count)
      when :log
        count = Math::log10(count) if count > 0
      else
        raise "Invalid strategy: #{strategy}"
      end
      results[name] = count > 0 ? count.to_f / total_count : 0.0
    end
    return results
  end

  # Classify a text by taking the average of all word classifications.
  def classify_text(words, strategy=:sum)
    hits = 0
    if strategy==:unique
      words = words & unique_words
    end
    group_score_sums = words.inject({}) do |results, word|
      word_results = classify(word, strategy)
      next results if word_results.empty?
      hits += 1
      results.merge(word_results) do |key, old, new|
        old + new
      end
    end

    averages={}
    group_score_sums.each do |group, sum|
      averages[group] = hits > 0 ? sum / hits : 0
    end

    averages
  end

  def self.version
    File.read(File.join(File.dirname(File.expand_path(__FILE__)), "..", "VERSION")).strip
  end
end