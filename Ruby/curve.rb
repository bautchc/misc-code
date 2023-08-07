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

# A class for calculating the average number of reviews per rating based on the average rating curves of Goodreads and
# Rate Your Music.
#
# Data Source
# RYM: https://rateyourmusic.com/discussion/rate-your-music/the-rym-global-average-rating/
# Goodreads: https://www.kaggle.com/datasets/bahramjannesarr/goodreads-book-datasets-10m

class Curve
  SETTINGS_OPTIONS = {
    :rym => {
      0.5 => 0.0102,
      1 => 0.0144,
      1.5 => 0.0171,
      2 => 0.0399,
      2.5 => 0.0669,
      3 => 0.1561,
      3.5 => 0.2239,
      4 => 0.2647,
      4.5 => 0.1308,
    },
    :goodreads => {
      1 => 0.021958228974588996,
      2 => 0.04804787991368406,
      3 => 0.17705222135841334,
      4 => 0.31708382162673954
    }
  }

  SETTINGS_ALIASES = {
    :rym => :rym,
    :r => :rym,
    :goodreads => :goodreads,
    :g => :goodreads
  }

  # (?Symbol) -> none
  def initialize(settings = :rym)
    @settings = SETTINGS_OPTIONS[SETTINGS_ALIASES[settings]]
  end

  # (Integer) -> none
  def calc(reviews)
    (0..4).map { |i| i + 0.5 }
          .zip(1..4)
          .flatten
          [0...-1]
          .each { |star| puts "#{star}: #{(@settings[star] * reviews).round}" if @settings[star] }

    puts "5: #{reviews - @settings.values.sum}"
  end

  # () -> none
  def inspect
    "#{@settings.inspect}, 5 => #{1 - @settings.values.sum}"
  end

  alias_method :c, :calc
end

C = Curve
