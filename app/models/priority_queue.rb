class PriorityQueue
  def initialize
    @list = []
  end

  def add(priority, item)
    @list << [priority, item]
    @list = @list.sort_by{|x| x[0]}
    self
  end

  def next
    @list.shift[1]
  end

  def empty?
    @list.empty?
  end
end