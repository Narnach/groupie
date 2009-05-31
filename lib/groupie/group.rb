class Groupie
  class Group
    def initialize(name)
      @name = name
      @entries = []
    end

    def add(*new_entries)
      @entries.concat(new_entries.flatten)
      nil
    end

    def count(entry)
      @entries.inject(0) do |count, element|
        element == entry ? count + 1 : count
      end
    end
  end
end