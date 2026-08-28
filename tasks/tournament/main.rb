require_relative 'tournament'
require_relative 'fighters/warrior'
require_relative 'fighters/mage'
require_relative 'modules/critical_hits'

critical_hit_warrior = Warrior.new("Conan");
critical_hit_warrior.singleton_class.include(CriticalHits)

fighters = [
  critical_hit_warrior,
  Mage.new("Gandalf"),
  Warrior.new("Garrett")
]

tournament = Tournament.new(fighters)
winner = tournament.run
puts "The winner is #{winner.name}"