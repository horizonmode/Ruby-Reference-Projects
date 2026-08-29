my_lambda1 = -> { "Hi" }
my_lambda2 = ->(x) { "Hello #{x}" }
my_lambda3 = lambda { |x| "Hello #{x}" }

my_proc = proc { |x| "Hello #{x}" }

puts my_lambda1.call
puts my_lambda2.call("World")
puts my_lambda3.call("World")
puts my_proc.call("World")

puts my_lambda2.("test")

arr = [1, 2, 3, 4, 5]
arr.each do |num|
  if (num == 3)
    next
  else
    puts my_lambda2.call(num)
  end
end

square = ->(x) { x * x }
puts square.call(5)
puts square.(3)
puts square[3]
puts square === 3
