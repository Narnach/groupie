class Groupie
  class Group
    def initialize(name)
      @name = name
      @entries = []
    end
    
    def add(*new_entries)
      @entries.concat(new_entries.flatten)
      @entries.uniq!
      nil
    end
    
    def contains?(entry)
      @entries.include?(entry)
    end
  end
end