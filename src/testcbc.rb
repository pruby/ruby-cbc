$:.unshift(File.dirname(__FILE__))

require 'ruby-cbc'

lp = RubyCBC::Problem.new
x = lp.integer(0..1000)
y = lp.integer(0..1000)

lp.constraint(x * 2 + y <= 1000)

lp.maximise(x * 2 + y)

lp.solve
