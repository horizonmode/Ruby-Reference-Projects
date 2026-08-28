class TelemetryStream
  include Enumerable

  def initialize(source:, transformer: ->(x) { x })
    @source = source
    @transformer = transformer
  end

  def each
    return enum_for(:each) unless block_given?
    @source.each do |reading|
      transformed_reading = @transformer.call(reading)
      yield transformed_reading
    end
  end

  def where(&predicate)
    raise ArgumentError, "Predicate block is required" unless predicate
    Enumerator.new do |output|
      each { |reading| output << reading if predicate.call(reading) }
    end
  end
end
