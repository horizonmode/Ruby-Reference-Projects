require_relative "../test_helper"
require_relative "../../tasks/book/book.rb"
class BookTest < Minitest::Test
  def test_book_initially_not_checked_out
    book = Book.new("Sample Book", "Sample Author")
    refute_predicate book, :checked_out?
  end

  def test_checking_out_a_book
    book = Book.new("Sample Book", "Sample Author")
    book.checkout
    assert_predicate book, :checked_out?
  end

  def test_returning_a_book
    book = Book.new("Sample Book", "Sample Author")
    book.checkout
    book.return_book
    refute_predicate book, :checked_out?
  end

  def test_returning_a_book_that_was_not_checked_out
    book = Book.new("Sample Book", "Sample Author")
    book.return_book
    refute_predicate book, :checked_out?
  end

  def test_title_returns_the_correct_title
    book = Book.new("Sample Book", "Sample Author")
    assert_equal "Sample Book", book.title
  end
end
