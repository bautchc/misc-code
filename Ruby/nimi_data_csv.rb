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

# A simple class that I used to clean the data from the following text files into something more usable:
# * http://tokipona.org/nimi_pu.txt
# * http://tokipona.org/nimi_pi_pu_ala.txt
# * http://tokipona.org/compounds.txt

require 'csv' # license: BSD-2-Clause

if __FILE__ == $PROGRAM_NAME
  vocab = ARGF.reduce(Hash.new) |vocab, line| do
            match = line.match(/^([^:]+): \[([^,\]]+(?:, [^,\]]+){0,2})/)
            unless vocab.has_key?(match[1])
              vocab[match[1]] = match[2].gsub(/ \(\d[^)]*\)/, '')
                                        .gsub(/(?<= )(?:\d|10)(?=,|$)/, '(0.5)')
                                        .gsub(/1\d(?!0)|20/, '(1)')
                                        .gsub(/[23]\d|40/, '(2)')
                                        .gsub(/[45]\d|60/, '(3)')
                                        .gsub(/[67]\d|80/, '(4)')
                                        .gsub(/[89]\d|100/, '(5)')
            end
            vocab
          end

  CSV.open('toki_pona_vocab.csv', 'wb') do |csv|
    vocab.each do |word, definition|
      csv << [word, definition]
    end
  end
end
