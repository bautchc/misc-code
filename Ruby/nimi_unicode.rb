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

# A script that helps assigning arbitrary unicode codepoints to compound Toki Pona words. I use it as part of a somewhat
# hacky Toki Pona typesetting system.
#
# ARGV[0]: path to ruby file containing a Hash called "WORD_CONVERSIONS" that maps Toki Pona words to unicode codepoints

require 'set' # BSD-2-Clause
load ARGV[0]

# Points corresponding to words that shouldn't show up in compounds. These are used in cases where an arbitrary
# codepoint is needed to represent an alternate version of a word.
WC_POINTS = %w[00 09]

# (String, String) -> String
def find_point(point1, point2)
  used_points = WORD_CONVERSIONS.values
                                .map { |value| to_codepoint(value) }
                                .to_set

  return "F#{point1}#{point2}" unless used_points.include?("F#{point1}#{point2}")

  point1 = point2 if point1 == '00'
  [point1, point2].each |point_end| do
    WC_POINTS.each do |point_start|
      return "F#{point_start}#{point_end}" unless used_points.include?("F#{point_start}#{point_end}")
    end
  end

  puts "\e[31mAdd more wild card points\e[0m"
end

# (String) -> String
def get_code(nimi)
  to_codepoint(WORD_CONVERSIONS[nimi])[-2, 2]
end

# (String) -> String
def to_codepoint(string)
  string.each_codepoint
        .to_a
        .filter { |codepoint| codepoint >= 0xF0000 }[0]
        .to_s(16)
end

if __FILE__ == $PROGRAM_NAME
  ARGF.each do |compound|
    nimi = compound.split(/-|_|\+/)
    codepoint = if nimi.include?('')
                  find_point('00', to_codepoint(WORD_CONVERSIONS[nimi.filter { |word| word != '' }[0]])[-2, 2])
                else
                  find_point(
                              to_codepoint(WORD_CONVERSIONS[nimi[0]])[-2, 2],
                              to_codepoint(WORD_CONVERSIONS[nimi[1]])[-2, 2]
                            )
                end
    puts "'#{compound}' => \"\\u{#{codepoint}}\","
  end
end
