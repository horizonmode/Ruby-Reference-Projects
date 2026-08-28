one = 10 * 2
two = 500 / 100;
sum = 1 + 2 + 3 + 4 + 5;

puts "The value of one is #{one}";
puts "The value of two is #{two}";
puts "The value of sum is #{sum}";

ip_to_domain = { "rubyguides.com" => "185.14.187.159", "example.com" => "93.184.216.34" }
puts ip_to_domain["rubyguides.com"]

h = {foo: 0, bar: 1, baz: 2}
puts h[:foo]

numbers = [1, 3, 5, 7]
numbers.each do |number|
  puts number
end

animals = ["cat", "dog", "tiger"]
animals.each_with_index { |animal, idx| puts "We have a #{animal} with index #{idx}" }


(0...10).select(&:even?).each { |n| puts n }

def hello_world
  puts "Hello, world!"
end

hello_world

class Book
  attr_reader :title, :author
  @@count = 0
  def initialize(title, author)
    @title  = title
    @author = author
    @@count += 1
  end
  def what_am_i
    puts "I'm a book!"
    puts :title.object_id
  end
  def self.what_am_i
    puts "I'm a class method!"
  end
  def self.count
    @@count
  end
end

class Cat
  attr_reader :name, :title
  def initialize(name)
    @name = name
    @title = "Cat"
  end
  def meow
    puts "#{@name} says meow!"
    puts :title.object_id
  end
end

book = Book.new("The Great Gatsby", "F. Scott Fitzgerald")
puts book.title
book.what_am_i
Book.what_am_i
book2 = Book.new("1984", "George Orwell")
puts Book.count

cat = Cat.new("Whiskers")
puts cat.name
puts cat.title
cat.meow