class StandardPricing
  def calculate(item, catalog_item, days)
    item.quantity * catalog_item.daily_rate * days
  end
end
