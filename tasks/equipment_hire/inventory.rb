class Inventory
  Item = Struct.new(:product_id, :quantity)
  def initialize(items = [])
    @items = items
    @bookings = []
  end

  def all_items
    @items.dup
  end

  def reserve(booking)
    @bookings << booking
  end

  def available_for?(request)
    request
      .items
      .group_by(&:product_id)
      .all? do |product_id, items|
        available?(
          product_id: product_id,
          quantity: items.sum(&:quantity),
          starts_on: request.starts_on,
          days: request.days
        )
      end
  end

  def dates_overlap?(existing:, starts_on:, days:)
    existing_start = existing.starts_on
    existing_end = existing.starts_on + existing.days
    requested_end = starts_on + days

    existing_start < requested_end && starts_on < existing_end
  end

  def available?(product_id:, quantity:, starts_on:, days:)
    item_quantity =
      @items.select { |item| item.product_id == product_id }.sum(&:quantity)
    items_hired_out =
      @bookings
        .select do |booking|
          request = booking.request
          request.items.any? { |item| item.product_id == product_id } &&
            dates_overlap?(existing: request, starts_on: starts_on, days: days)
        end
        .sum do |booking|
          request = booking.request
          request
            .items
            .select { |item| item.product_id == product_id }
            .sum(&:quantity)
        end
    item_quantity - items_hired_out >= quantity
  end
end
