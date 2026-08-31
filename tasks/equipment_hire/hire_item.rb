class HireItem
  require_relative "product"

  attr_reader :product_id, :quantity

  def initialize(product_id:, quantity:)
    unless Product::PRODUCTIDs.include?(product_id)
      raise ArgumentError,
            "product_id must be one of #{Product::PRODUCTIDs.join(", ")}"
    end
    unless quantity.is_a?(Integer) && quantity.positive?
      raise ArgumentError, "quantity must be a positive integer"
    end
    @product_id = product_id
    @quantity = quantity
  end
end
