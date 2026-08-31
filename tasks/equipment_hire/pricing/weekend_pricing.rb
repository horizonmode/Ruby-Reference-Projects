class WeekendPricingModel
  def calculate(item, catalog_item, days)
    (item.quantity * catalog_item.daily_rate * days) * 1.2
  end
end
