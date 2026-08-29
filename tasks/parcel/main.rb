require_relative "parcel"
require_relative "parcel_manifest"

parcels = [
  Parcel.new(
    id: "P-100",
    destination: "London",
    weight: 4.5,
    priority: :standard
  ),
  Parcel.new(
    id: "P-101",
    destination: "Manchester",
    weight: 2.0,
    priority: :express
  ),
  Parcel.new(
    id: "P-102",
    destination: "London",
    weight: 5.0,
    priority: :express
  ),
  Parcel.new(
    id: "P-103",
    destination: "Bristol",
    weight: 6.0,
    priority: :standard
  ),
  Parcel.new(
    id: "P-104",
    destination: "London",
    weight: 3.0,
    priority: :standard
  )
]

priority_sorter =
  lambda do |items|
    items.sort_by { |parcel| parcel.priority == :express ? 0 : 1 }
  end

manifest = ParcelManifest.new(parcels: parcels, sorter: priority_sorter)

puts "All parcels:"
manifest.each do |parcel|
  puts "#{parcel.id}: #{parcel.destination}, " \
         "#{parcel.weight}kg, #{parcel.priority}"
end

puts
puts "Parcel IDs:"
puts manifest.map(&:id).join(", ")

puts
puts "Express parcels:"
manifest.express.each { |parcel| puts "#{parcel.id}: #{parcel.destination}" }

puts
puts "Parcels going to London:"
london_parcels =
  manifest.for_destination { |destination| destination.casecmp?("London") }

london_parcels.each { |parcel| puts "#{parcel.id}: #{parcel.weight}kg" }

puts
puts "Total weight: #{manifest.total_weight}kg"

puts
puts "Heaviest parcel:"
heaviest = manifest.max_by(&:weight)
puts "#{heaviest.id}: #{heaviest.weight}kg"

puts
puts "Find parcel P-102:"
found = manifest.find_by_id("P-102")

if found
  puts "#{found.id} is going to #{found.destination}"
else
  puts "Parcel not found"
end

puts
puts "Parcels grouped by destination:"
manifest
  .group_by(&:destination)
  .each do |destination, items|
    ids = items.map(&:id).join(", ")
    puts "#{destination}: #{ids}"
  end

puts
puts "Delivery batches with a maximum weight of 10kg:"
manifest.each_batch(10) do |batch|
  ids = batch.map(&:id).join(", ")
  weight = batch.sum(&:weight)

  puts "#{ids} — #{weight}kg"
end

puts
puts "Manual enumerator usage:"
enumerator = manifest.each

begin
  loop do
    parcel = enumerator.next
    puts "Next parcel: #{parcel.id}"
  end
end
