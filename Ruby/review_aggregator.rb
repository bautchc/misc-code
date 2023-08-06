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

# Takes a csv containing review information such that many rows can have the same company name and aggregates them.
#
# Should be in a folder containing a single csv with the format specified below.
#
# ARVG[0]: The output path

require 'csv' # license: BSD-2-Clause

# (String) -> [[String, String, String], Hash[String, Array[[String, String]]]]
def read_csv(file_path)
  # Takes in a csv with the following format:
  #
  # PROJECT NAME, NUM REVIEWS, AVERAGE
  # some name, 1, 4.9
  # some name, 0, -
  # another name, 2, 5
  title = nil
  # data is a hash that maps name to an array of [num, average] pairs
  data = Hash.new { |hash, key| hash[key] = [] }
  first_row = true

  CSV.foreach(file_path) do |row|
    if first_row
      title = row.take(3)
      first_row = false
    else
      # skip empty rows
      next unless row[0]

      data[row[0]] << row[1, 2]
    end
  end

  [title, data]
end

# (Hash[String, Array[[String, String]]]) -> Hash[String, Array[[String|Integer, String|Double]]]
def aggregate_reviews(review_hash)
  review_hash.each do |name, review_pairs|
    review_hash[name] = if review_pairs.length > 1
                          total_reviews = 0
                          total_avg = 0
                          review_pairs.each do |reviews, avg|
                            reviews = reviews.to_i
                            next if reviews.zero?

                            total_reviews += reviews
                            total_avg += reviews * avg.to_f
                          end
                          [total_reviews, total_reviews.zero? ? '-' : (total_avg / total_reviews).round(2)]
                        else
                          review_pairs.flatten
                        end
  end

  review_hash
end

# (Hash[String, Array[[String|Integer, String|Double]]]) -> void
def write_csv(file_path, title, data)
  CSV.open(file_path, 'wb') do |csv|
    csv << title
    data.each { |name, review_pair| csv << review_pair.prepend(name) }
  end
end

if __FILE__ == $PROGRAM_NAME
  title, data = read_csv(Dir.glob('*.csv')[0])
  write_csv(ARGV[0], title, aggregate_reviews(data))
end
