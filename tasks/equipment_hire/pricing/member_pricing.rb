class MemberPricingModel
  def calculate(item, catalog_item, days)
    (item.quantity * catalog_item.daily_rate * days) * 0.9
  end
end
