require_relative 'book.rb'

book1 = Book.new("The Great Gatsby", "F. Scott Fitzgerald")
book2 = Book.new("1984", "George Orwell")
book3 = Book.new("To Kill a Mockingbird", "Harper Lee")
book4 = Book.new("Pride and Prejudice", "Jane Austen")
book5 = Book.new("The Catcher in the Rye", "J.D. Salinger")

books = [book1, book2, book3, book4, book5]

books.each do |book|
  book.info
end

class Library
  attr_accessor :books
  attr_reader :checkout_history

  def initialize(books)
    @books = books
    @checkout_history = Hash.new { |hash, key| hash[key] = [] }
  end

  def list_books
    @books.each do |book|
      book.info
    end
  end

  def checkout_book(title)
    selected_book = @books.find { |book| book.title.downcase == title.downcase }

    if selected_book
      if selected_book.checked_out
        puts "Sorry, '#{selected_book.title}' is already checked out."
      else
        selected_book.checkout
        @checkout_history[selected_book.title] << Time.now
        puts "You have checked out '#{selected_book.title}'."
      end
    else
      puts "Book not found."
    end
  end

  def return_book(title)
    selected_book = @books.find { |book| book.title.downcase == title.downcase }

    if selected_book
      if selected_book.checked_out
        selected_book.return_book
        puts "You have returned '#{selected_book.title}'."
      else
        puts "'#{selected_book.title}' was not checked out."
      end
    else
      puts "Book not found."
    end
  end

  def checkout_history_for(title)
    if @checkout_history.key?(title)
      puts "Checkout history for '#{title}':"
      @checkout_history[title].each do |timestamp|
        puts timestamp
      end
    else
      puts "No checkout history for '#{title}'."
    end
  end
end

library = Library.new(books)

until false
  print "Enter the title of the book you want to check out (or type 'exit' to quit): "
  input = gets.chomp

  break if input.downcase == 'exit'

  library.checkout_book(input)
end

books.select(&:checked_out).each do |book|
  library.checkout_history_for(book.title)
end