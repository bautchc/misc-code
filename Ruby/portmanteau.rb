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

# Takes a list of words and finds all ideal portmanteaus between them, where an ideal portmanteau is defined as as a
# portmanteau where the first word is a one-syllable word that creates the entire first syllable of the portmanteau and
# the second word is a two-syllable word such that the second syllable of the second word creates the second syllable of
# the portmanteau and the last n letters of the first syllable of the second word match the last n letters of the first
# word. For example, "bread.sheet (b[read] sp[read].sheet)".
#
# This program uses the dataset, 'Syllables.txt', found here: http://www.delphiforfun.org/programs/Syllables.htm
# However, any dataset that contains a text file of lines in the following format will work:
#
# syllables=syl\xB7la\xB7bles
# (where \xB7 is a literal byte that is not encoded in UTF-8)
#
# ARGV[0]: Minimum number of letters that must be shared between the first and second words of a portmanteau

MIN_SHARED = ARGV[0] || 4

# (String, String, List[String]) -> String?
def test_overlap(pre, post, all)
  syls = post.split('�')
  # Test from highest overlap to lowest
  max = [pre.length - 1, post.index('�')].min
  (4..max).each do |i|
    overlap = max - i + 4
    if pre[-overlap...] == syls[0][-overlap...] && !all.includes?(pre + syls[1])
      return "#{pre} + #{post} = #{pre + syls[1]}"
    end
  end

  # Return nil if no overlap is found
  nil
end

# () -> [List[String], List[String], List[String]]
def read_valid_words
  first = []
  second = []
  all = []
  File.foreach(Dir.glob('*.txt')[0]) do |line|
    # Source text uses a \xB7 byte as a syllable separator, which is not encoded in UTF-8, so that's replaced with the
    # \uFFFD character
    line = line.encode('UTF-8', :invalid => :replace)
               .chomp
    words = line.split('=')
    all << word[0]
    word = word[1]
    syls = word.split('�')
    # Only 1-syllable words can be the pre word, and only 2-syllable words can be the post word
    case syls.length
    when 1 then first << word if word.length > MIN_SHARED
    when 2 then second << word if syls[0].length >= MIN_SHARED
    end
  end

  [first, second, all]
end

# (List[String], List[String], List[String]) -> List[String]
def find_ports(first, second, all)
  first.reduce([]) do |ports, pre|
    second.each do |post|
      overlap = test_overlap(pre, post, all)
      ports << overlap if overlap else ports
    end
  end
end

# () -> void
def main
  find_ports(*read_valid_words).each { |s| puts s }
end

main if __FILE__ == $PROGRAM_NAME
