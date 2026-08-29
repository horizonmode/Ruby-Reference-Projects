require_relative "../test_helper"
require_relative "../../tasks/parcel/parcel_manifest"

class ParcelManifestTest < Minitest::Test
  def setup
    @standard = build_parcel(id: "P-100", destination: "London", weight: 4)
    @express =
      build_parcel(
        id: "P-101",
        destination: "Bristol",
        weight: 3,
        priority: :express
      )
    @express_london =
      build_parcel(
        id: "P-102",
        destination: "London",
        weight: 6,
        priority: :express
      )
    @parcels = [@standard, @express, @express_london]
    @manifest = ParcelManifest.new(parcels: @parcels)
  end

  def test_is_an_enumerable
    assert_kind_of Enumerable, @manifest
  end

  def test_each_yields_every_parcel_in_original_order_by_default
    assert_equal %w[P-100 P-101 P-102], @manifest.map(&:id)
  end

  def test_each_returns_an_enumerator_without_a_block
    enumerator = @manifest.each

    assert_instance_of Enumerator, enumerator
    assert_same @standard, enumerator.next
  end

  def test_standard_enumerable_operations_work
    assert_equal 3, @manifest.count
    assert_equal [@express, @express_london],
                 @manifest.select { |parcel| parcel.priority == :express }
    assert_same @express_london, @manifest.max_by(&:weight)
    assert_equal(
      { "London" => 2, "Bristol" => 1 },
      @manifest.group_by(&:destination).transform_values(&:count)
    )
  end

  def test_constructor_defensively_copies_the_supplied_collection
    @parcels.clear

    assert_equal %w[P-100 P-101 P-102], @manifest.map(&:id)
  end

  def test_add_parcel_adds_it_to_the_manifest
    added = build_parcel(id: "P-103", destination: "Manchester", weight: 2)

    @manifest.add_parcel(added)

    assert_includes @manifest, added
    assert_equal 4, @manifest.count
  end

  def test_injected_sorter_controls_iteration_order
    heaviest_first = ->(parcels) { parcels.sort_by(&:weight).reverse }
    manifest = ParcelManifest.new(parcels: @parcels, sorter: heaviest_first)

    assert_equal %w[P-102 P-100 P-101], manifest.map(&:id)
  end

  def test_express_returns_an_enumerator_with_only_express_parcels
    result = @manifest.express

    assert_instance_of Enumerator, result
    assert_equal %w[P-101 P-102], result.map(&:id)
  end

  def test_for_destination_filters_lazily_with_its_predicate
    result =
      @manifest.for_destination { |destination| destination.casecmp?("london") }

    assert_instance_of Enumerator::Lazy, result
    assert_equal %w[P-100 P-102], result.map(&:id).force
  end

  def test_for_destination_requires_a_predicate
    error = assert_raises(ArgumentError) { @manifest.for_destination }

    assert_equal "Predicate must be provided", error.message
  end

  def test_total_weight_sums_parcel_weights
    assert_equal 13, @manifest.total_weight
  end

  def test_empty_manifest_has_zero_total_weight
    manifest = ParcelManifest.new(parcels: [])

    assert_equal 0, manifest.total_weight
  end

  def test_find_by_id_returns_the_matching_parcel
    assert_same @express, @manifest.find_by_id("P-101")
  end

  def test_find_by_id_returns_nil_when_no_parcel_matches
    assert_nil @manifest.find_by_id("missing")
  end

  def test_each_batch_groups_parcels_without_exceeding_the_limit
    batches = @manifest.each_batch(7).to_a

    assert_equal [%w[P-100 P-101], %w[P-102]],
                 batches.map { |batch| batch.map(&:id) }
    assert batches.all? { |batch| batch.sum(&:weight) <= 7 }
  end

  def test_each_batch_returns_an_enumerator_without_a_block
    result = @manifest.each_batch(7)

    assert_instance_of Enumerator, result
  end

  def test_each_batch_returns_no_batches_for_an_empty_manifest
    manifest = ParcelManifest.new(parcels: [])

    assert_empty manifest.each_batch(10).to_a
  end

  def test_each_batch_rejects_a_parcel_over_the_limit
    parcel = build_parcel(id: "P-HEAVY", weight: 11)
    manifest = ParcelManifest.new(parcels: [parcel])

    assert_raises(ArgumentError) { manifest.each_batch(10).to_a }
  end

  def test_each_batch_requires_a_positive_maximum_weight
    [0, -1].each do |maximum|
      assert_raises(ArgumentError) { @manifest.each_batch(maximum).to_a }
    end
  end

  def test_lazy_enumeration_can_read_a_finite_part_of_an_infinite_source
    sequence = 0
    source =
      Enumerator.new do |output|
        loop do
          sequence += 1
          output << build_parcel(id: "P-#{sequence}", weight: sequence)
        end
      end
    manifest = ParcelManifest.new(parcels: source)

    assert_equal %w[P-1 P-2 P-3], manifest.lazy.take(3).map(&:id).force
  end

  private

  def build_parcel(
    id: "P-100",
    destination: "London",
    weight: 1,
    priority: :standard
  )
    Parcel.new(
      id: id,
      destination: destination,
      weight: weight,
      priority: priority
    )
  end
end
