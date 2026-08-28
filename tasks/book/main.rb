require_relative "book.rb"
require_relative "library.rb"

book1 = Book.new("The Great Gatsby", "F. Scott Fitzgerald")
book2 = Book.new("1984", "George Orwell")
book3 = Book.new("To Kill a Mockingbird", "Harper Lee")
book4 = Book.new("Pride and Prejudice", "Jane Austen")
book5 = Book.new("The Catcher in the Rye", "J.D. Salinger")

books = [book1, book2, book3, book4, book5]

books.each { |book| book.info }

library = Library.new(books)

until false
  print "Enter the title of the book you want to check out (or type 'exit' to quit): "
  input = gets.chomp

  break if input.downcase == "exit"

  library.checkout_book(input)
end

books
  .select(&:checked_out)
  .each { |book| library.checkout_history_for(book.title) }
