require_relative "../../tasks/book/library.rb"
require_relative "../../tasks/book/book.rb"
require "minitest/autorun"

class LibraryTest < Minitest::Test
  def setup
    @book1 = Book.new(title: "The Great Gatsby", author: "F. Scott Fitzgerald")
    @book2 = Book.new(title: "1984", author: "George Orwell")
    @book3 = Book.new(title: "To Kill a Mockingbird", author: "Harper Lee")
    @books = [@book1, @book2, @book3]
    @library = Library.new(@books)
  end

  def test_checkout_book
    @library.checkout_book("1984")
    assert_predicate @book2, :checked_out?
  end

  def test_return_book
    @library.checkout_book("1984")
    @library.return_book("1984")
    refute_predicate @book2, :checked_out?
  end

  def test_checkout_history
    @library.checkout_book("1984")
    assert_equal 1, @library.checkout_history["1984"].size
  end
end
