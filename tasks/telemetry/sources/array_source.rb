class ArraySource
  include Enumerable
  def initialize(array: [])
    @array = array
  end

  def each(&block)
    @array.each(&block)
  end
end
