require_relative "errors"
require_relative "product"

module EquipmentHire
  class Catalog
    include Enumerable

    def initialize(products)
      unless products.is_a?(Array) && !products.empty? &&
               products.all? { |product| product.is_a?(Product) }
        raise ArgumentError, "products must be a non-empty array of Products"
      end
      unless products.map(&:id).uniq.length == products.length
        raise ArgumentError, "product IDs must be unique"
      end

      @products = products.dup.freeze
    end

    def each(&block)
      products.each(&block)
    end

    def fetch(product_id)
      find { |product| product.id == product_id } ||
        raise(UnknownProductError, "unknown product: #{product_id}")
    end

    def all_products
      products.dup.freeze
    end

    private

    attr_reader :products
  end
end
