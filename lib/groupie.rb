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

  def classify(entry)
    results = {}
    total_count = @groups.inject(0) do |sum, name_group|
      group = name_group.last
      sum + group.count(entry)
    end
    return results if 0 == total_count

    @groups.each do |name, group|
      count = group.count(entry)
      results[name] = count > 0 ? count.to_f / total_count : 0.0
    end
    return results
  end

  # Classify a text by taking the average of all word classifications.
  def classify_text(words)
    group_score_sums = words.inject({}) do |results, word|
      word_results = classify(word)
      results.merge(word_results) do |key, old, new|
        old + new
      end
    end

    words_count = words.size.to_f
    averages={}
    group_score_sums.each do |group, sum|
      averages[group] = sum / words_count
    end

    averages
  end
  
  def self.version
    File.read(File.join(File.dirname(File.expand_path(__FILE__)), "..", "VERSION")).strip
  end
end