module EnumeratorSpecs

  class Numerous
    include Enumerable
    def initialize(*list)
      @list = list.empty? ? [2, 5, 3, 6, 1, 4] : list
    end

    def each
      return to_enum unless block_given?
      @list.each { |i| yield i }
    end

    def more(*list)
      @list += list
    end
  end

  class SizedNumerous < Numerous
    def size
      @list.size
    end
  end
end