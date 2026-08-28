require_relative './modules/damageable.rb'
require_relative './modules/healable.rb'

class Fighter
  include Damageable
  include Healable

  attr_reader :name, :damage, :max_health
  attr_accessor :health

  def initialize(name:, damage:, health:)
    @name = name
    @damage = damage
    @health = health
    @max_health = health
    @healed_this_battle = false
  end

  def attack(target)
    target.take_damage(damage)
  end

  def alive?
    health.positive?
  end

  def should_heal?
    health < max_health
  end

  def heal_once
    if should_heal? && !@healed_this_battle
      heal(10)
      @healed_this_battle = true
    end
  end

  def reset_for_battle
    @healed_this_battle = false
  end

  def status
    "#{name} - Health: #{health}/#{max_health}, Damage: #{damage}"
  end

  private 

  def critical_hit?
    rand < 0.1
  end
end