class Book 
  attr_accessor :title, :author, :checked_out
  def initialize(title, author)
    @title = title
    @author = author
    @checked_out = false
  end

  def checkout
    @checked_out = true
  end

  def return_book
    @checked_out = false
  end

  def info
    puts "Title: #{@title}, Author: #{@author}, Checked Out: #{@checked_out}"
  end
end