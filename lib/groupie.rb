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

  def classify(entry, strategy=:sum)
    results = {}
    total_count = @groups.inject(0) do |sum, name_group|
      group = name_group.last
      if strategy==:sum
        sum + group.count(entry)
      elsif strategy==:sqrt
        sum + Math::sqrt(group.count(entry))
      elsif strategy==:log
        sum + Math::log10(group.count(entry))
      else
        raise "Invalid strategy: #{strategy}"
      end
    end
    return results if 0 == total_count

    @groups.each do |name, group|
      if strategy==:sum
        count = group.count(entry)
      elsif strategy==:sqrt
        count = Math::sqrt(group.count(entry))
      elsif strategy==:log
        count = Math::log10(group.count(entry))
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