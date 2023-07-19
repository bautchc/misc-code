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

# A simple class for adding up times as minutes or hours. I plut it into my .irbc files to make my
# workflow a little easier.

class Time
  # (Integer) -> String
  def initialize(start_time = 0)
    @minutes = 0
    @hours = 0
    add(start_time)
  end

  # (Integer) -> String
  def add(other)
    @hours += other / 100 + (@minutes + other % 100) / 60
    @minutes = (@minutes + other % 100) % 60
    inspect
  end

  # (Integer) -> String
  def subtract(other)
    @hours -= other / 100 + (@minutes - other % 100) / 60
    @minutes = (@minutes - other % 100) % 60
    inspect
  end

  # (Array[Integer]) -> String
  def self.adds(others)
    temp = Time.new
    others.each { |other| temp.add(other) }
    temp.inspect
  end

  # () -> void
  def argf
    ARGF.each { |arg| puts add(arg.chomp.to_i) }
  end

  # () -> String
  def inspect
    "#{@hours}:#{@minutes.to_s.rjust(2, '0')}"
  end

  alias a add
  alias s subtract
  alias ar argf
  class << self
    alias as adds
  end
end

T = Time
