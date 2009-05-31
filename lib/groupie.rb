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
      results[name] = count.to_f / total_count if count > 0
    end
    return results
  end
end