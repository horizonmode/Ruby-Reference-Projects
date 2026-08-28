def hello_world
  puts "Hello, world!"
end

class Person 
    
  attr_accessor :name

  def initialize(name)
    @name = internal_greet(name)
  end

  private
  def internal_greet(name)
    @name = "My name is, #{name}!"
  end

  public
  def greet
    puts "Hello, #{@name}!"
  end
end

class Greeter

  def initialize
   @people = []
  end

  def addPerson(name)
    person = Person.new(name)
    @people << person
  end

  def greet
    @people.each do |person|
      person.greet
    end

    puts "Timeframes: #{TIMEFRAMES.join(', ')}"
  end

end

greeter = Greeter.new()
greeter.addPerson("World")
greeter.addPerson("Ruby")
greeter.greet