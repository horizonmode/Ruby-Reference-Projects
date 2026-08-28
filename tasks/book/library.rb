require_relative "book.rb"

class Library
  attr_accessor :books
  attr_reader :checkout_history

  def initialize(books)
    @books = books
    @checkout_history = Hash.new { |hash, key| hash[key] = [] }
  end

  def list_books
    @books.each { |book| book.info }
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
      @checkout_history[title].each { |timestamp| puts timestamp }
    else
      puts "No checkout history for '#{title}'."
    end
  end
end
