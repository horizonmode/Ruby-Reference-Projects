module Damageable
  def take_damage(amount)
    actual_damage = reduce_damage(amount)
    self.health = [health - actual_damage, 0].max
    actual_damage
  end

  def alive?
    health.positive?
  end

  private

  def reduce_damage(amount)
    amount
  end
end