require_relative '../fighter.rb'

class Warrior < Fighter
  def initialize(name)
    super(name: name, health: 100, damage: 20)
    @fireballs = 3
  end

  def attack(target)
    return super(target) unless critical_hit? && @fireballs.positive?
    @fireballs -= 1
    target.take_damage(damage * 2)
  end

  def reset_for_battle
    super
    @fireballs = 3
  end

  private

  def reduce_damage(amount)
    blocked = rand < 0.3
    blocked ? (amount * 0.5).round : amount
  end
end
