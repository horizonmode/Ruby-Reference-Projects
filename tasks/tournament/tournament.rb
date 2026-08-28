class Tournament
  def initialize(fighters)
    @fighters = fighters
  end

  def run_round
    puts "Starting a new round with #{@fighters.size} fighters."
    winners = []
    @fighters.shuffle!

    if @fighters.size.odd?
      bye_fighter = @fighters.pop
      puts "#{bye_fighter.name} gets a bye this round."
    end

    pairs = @fighters.each_slice(2).to_a
    pairs.each do |fighter1, fighter2|
      winners << run_battle(fighter1, fighter2)
    end

    winners << bye_fighter if bye_fighter
    @fighters = winners
  end


  def run_battle(fighter1, fighter2)
    puts "Battle between #{fighter1.name} and #{fighter2.name}!"
    while fighter1.alive? && fighter2.alive?
      fighter1.attack(fighter2)
      fighter2.attack(fighter1) if fighter2.alive?
      fighter1.heal_once
      fighter2.heal_once if fighter2.alive?
    end
    winner = fighter1.alive? ? fighter1 : fighter2
    puts "Winner: #{winner.name}"
    winner.reset_for_battle
    winner
  end


  def run 
    while @fighters.size > 1
      run_round
    end
    @fighters.first
  end
end