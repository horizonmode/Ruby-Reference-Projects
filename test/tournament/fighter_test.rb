require_relative "../test_helper"
require_relative "../../tasks/tournament/fighter"
require_relative "../../tasks/tournament/fighters/mage"
require_relative "../../tasks/tournament/fighters/warrior"
require_relative "../../tasks/tournament/modules/critical_hits"

class FighterTest < Minitest::Test
  def test_initial_state_and_status
    fighter = Fighter.new(name: "Robin", damage: 15, health: 60)

    assert_equal "Robin", fighter.name
    assert_equal 15, fighter.damage
    assert_equal 60, fighter.health
    assert_equal 60, fighter.max_health
    assert_predicate fighter, :alive?
    assert_equal "Robin - Health: 60/60, Damage: 15", fighter.status
  end

  def test_attack_tells_target_to_take_damage
    attacker = Fighter.new(name: "Attacker", damage: 25, health: 50)
    target = Minitest::Mock.new
    target.expect(:take_damage, 25, [25])

    attacker.attack(target)

    target.verify
  end

  def test_damage_does_not_reduce_health_below_zero
    target = Fighter.new(name: "Target", damage: 10, health: 20)

    target.take_damage(25)

    assert_equal 0, target.health
    refute_predicate target, :alive?
  end

  def test_heal_does_not_exceed_maximum_health
    fighter = Fighter.new(name: "Healer", damage: 10, health: 50)
    fighter.take_damage(5)

    fighter.heal(10)

    assert_equal 50, fighter.health
  end

  def test_heal_once_only_heals_once_until_reset
    fighter = Fighter.new(name: "Healer", damage: 10, health: 100)
    fighter.take_damage(30)

    fighter.heal_once
    assert_equal 80, fighter.health

    fighter.take_damage(10)
    fighter.heal_once
    assert_equal 70, fighter.health

    fighter.reset_for_battle
    fighter.heal_once
    assert_equal 80, fighter.health
  end
end

class WarriorTest < Minitest::Test
  def test_default_attributes
    warrior = Warrior.new("Conan")

    assert_equal "Conan", warrior.name
    assert_equal 100, warrior.health
    assert_equal 20, warrior.damage
  end

  def test_block_reduces_incoming_damage_by_half
    warrior = Warrior.new("Conan")

    damage_taken = warrior.stub(:rand, 0.1) { warrior.take_damage(21) }

    assert_equal 11, damage_taken
    assert_equal 89, warrior.health
  end

  def test_critical_attacks_are_limited_until_battle_reset
    warrior = Warrior.new("Conan")
    target = Fighter.new(name: "Target", damage: 1, health: 200)

    warrior.stub(:critical_hit?, true) do
      4.times { warrior.attack(target) }
      assert_equal 60, target.health

      warrior.reset_for_battle
      warrior.attack(target)
    end

    assert_equal 20, target.health
  end

  def test_battle_reset_allows_warrior_to_heal_again
    warrior = Warrior.new("Conan")
    warrior.health = 70
    warrior.heal_once
    warrior.health = 70

    warrior.reset_for_battle
    warrior.heal_once

    assert_equal 80, warrior.health
  end
end

class MageTest < Minitest::Test
  def test_default_attributes
    mage = Mage.new("Gandalf")

    assert_equal "Gandalf", mage.name
    assert_equal 80, mage.health
    assert_equal 25, mage.damage
  end

  def test_resistance_reduces_incoming_damage
    mage = Mage.new("Gandalf")

    damage_taken = mage.stub(:rand, 0.1) { mage.take_damage(20) }

    assert_equal 14, damage_taken
    assert_equal 66, mage.health
  end
end

class CriticalHitsTest < Minitest::Test
  def test_critical_hit_deals_double_damage
    attacker = Fighter.new(name: "Lucky", damage: 20, health: 100)
    target = Fighter.new(name: "Target", damage: 10, health: 100)
    attacker.singleton_class.include(CriticalHits)

    attacker.stub(:rand, 0.1) { quietly { attacker.attack(target) } }

    assert_equal 60, target.health
  end
end
