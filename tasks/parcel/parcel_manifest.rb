require_relative("parcel")
require_relative("constants")

class ParcelManifest
  include Enumerable

  def initialize(parcels:, sorter: ->(items) { items })
    @parcels = parcels.dup
    @sorter = sorter
  end

  def add_parcel(parcel)
    @parcels << parcel
  end

  def each
    return enum_for(:each) unless block_given?
    @sorter.call(@parcels.dup).each { |parcel| yield(parcel) }
  end

  def express
    return enum_for(:express) unless block_given?
    each { |parcel| yield(parcel) if parcel.priority == :express }
  end

  def for_destination(&predicate)
    raise ArgumentError, "Predicate must be provided" unless predicate
    lazy.select { |parcel| predicate.call(parcel.destination) }
  end

  def total_weight
    sum(&:weight)
  end

  def find_by_id(id)
    find { |parcel| parcel.id == id }
  end

  def each_batch(max_weight)
    if (max_weight <= 0)
      raise ArgumentError, "Maximum batch weight must be greater than zero"
    end
    return enum_for(:each_batch, max_weight) unless block_given?
    batch = []
    batch_weight = 0
    each do |parcel|
      if parcel.weight > max_weight
        raise ArgumentError, "Parcel weight exceeds maximum batch weight"
      end
      if batch_weight + parcel.weight > max_weight
        yield(batch)
        batch = []
        batch_weight = 0
      end
      batch << parcel
      batch_weight += parcel.weight
    end
    yield(batch) unless batch.empty?
  end
end
