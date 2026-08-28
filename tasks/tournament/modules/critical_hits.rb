module CriticalHits
  def attack(target)
    puts "#{name} is attacking #{target.name} with a potential critical hit!"
    amount = rand < 0.2 ? damage * 2 : damage
    target.take_damage(amount)
  end
end