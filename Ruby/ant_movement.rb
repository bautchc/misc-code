# frozen_string_literal: true

# MIT No Attribution
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# A script that I used for to simulate random walking for a puzzle I was solving that looked for the average number of
# steps needed to reach one of an arbitrary set of points from random walking on a 2D grid.

class Ant
  # goal is a boolean function that defines whether a point is a goal point based on the x and y coordinates

  # ({ (Integer, Integer) -> bool }) -> void
  def initialize(goal)
    @x_pos = 0
    @y_pos = 0
    @goal = goal
    @moves = 0
  end

  # () -> void
  def move?
    case rand(4)
    when 0
      @x_pos += 10
    when 1
      @x_pos -= 10
    when 2
      @y_pos += 10
    when 3
      @y_pos -= 10
    end
    @moves += 1
    is_goal?
  end

  # () -> bool
  def is_goal?
    instance_exec(@x_pos, @y_pos, &@goal)
  end

  # () -> Integer
  def move_to_goal
    until move? do end
    @moves
  end
end

class Array
  # Array[Elem] -> Array[Elem]
  def elementwise_add(other)
    self.zip(other).map { |a, b| a + b }
  end
end

# () -> void
def main
  goal1 = Proc.new {|x, y| x.abs == 20 || y.abs == 20}
  goal2 = Proc.new {|x, y| y == (10 - x)}
  goal3 = Proc.new {|x, y| ((x - 2.5) / 30 ) ** 2 + ((y - 2.5) / 40) ** 2 >= 1}
  totals = [0, 0]

  puts "How many simulations would you like to run?"
  num_simulations = gets.to_i

  (0...num_simulations).each do |_|
    totals = totals.elementwise_add([Ant.new(goal1), Ant.new(goal3)].map {|ant| ant.move_to_goal})
  end

  puts "1. #{totals[0] / num_simulations.to_f}"
  puts "2. #{totals[1] / num_simulations.to_f}"
  puts "3. #{totals[1] / num_simulations.to_f}"
end

if __FILE__ == $PROGRAM_NAME
  main
end
