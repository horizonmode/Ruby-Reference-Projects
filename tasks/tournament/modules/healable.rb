module Healable
  def heal(amount)
    self.health = [health + amount, max_health].min
  end
end