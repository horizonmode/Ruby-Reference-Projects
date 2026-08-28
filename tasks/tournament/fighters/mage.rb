require_relative '../fighter.rb'

class Mage < Fighter
  def initialize(name)
    super(name: name, health: 80, damage: 25)
  end

  private

  def reduce_damage(amount)
    resisted = rand < 0.2
    resisted ? (amount * 0.7).round : amount
  end
end