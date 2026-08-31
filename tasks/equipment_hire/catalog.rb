require_relative "product"

class Catalog
  include Enumerable
  def initialize(products)
    unless products.is_a?(Array)
      raise ArgumentError, "Products must be an array"
    end
    raise ArgumentError, "Products array cannot be empty" if products.empty?
    unless products.all? { |product| product.is_a?(Product) }
      raise ArgumentError,
            "All elements in products array must be Product instances"
    end
    @products = products
  end

  def all_products
    @products.dup
  end

  def each(&block)
    @products.each(&block)
  end
end
