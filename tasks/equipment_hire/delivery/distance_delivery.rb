class DistanceDelivery
  def initialize(distance_in_miles)
    @distance_in_miles = distance_in_miles
  end

  def cost()
    2 * @distance_in_miles
  end
end
