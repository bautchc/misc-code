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

# A script used to convert markdown pipe tables into optimized markdown grid tables.

# Maximum horizontal width of the table
LINE_WIDTH = 120
# Number of random tries to find a better solution. Making this larger will reduce the chance of missing the global
# maximum at the cost of runtime.
RANDOM_TRIES = 10_000

# Read pipe table from file and turn the cells into a 2D array

# () -> Array[Array[String]]
def get_input
  ARGF.reduce([]) { |cells, line| cells << line.chomp.split('|').map(&:strip)[1..] }
      .delete_at(1) # delete line of dashes
end

# Find an approximate optimal widths needed to minimize the length of the table. Uses hill climbing with a heuristic
# that gets close to the global maximum.

# (Array[Array[String]], Array[Integer]) -> Array[Integer]
def find_ballpark_widths(cells, max_word_lengths)
  # Initialize widths to be roughly equal
  widths = Array.new(cells[0].length, (LINE_WIDTH - 1 - (3 * cells[0].length)) / cells[0].length)
  widths[0] += (LINE_WIDTH - 1 - 3 * cells[0].length) % cells[0].length
  # Calculate the line lengths for each column. Note, this is the total lines for a table containing only that column,
  # not the actual length of the table when other columns are accounted for. This is used because using the actual
  # fitness value would cause our hill climbing to get stuck in shoulders.
  lines_map = to_lines_map(all_lines(cells, widths), widths, max_word_lengths)
  # Make the biggest column wider and smallest column thinner until the line length is minimized.
  climb_hill(cells, widths, lines_map, max_word_lengths)
end

# Create a hash mapping the number of lines in each column to the index of that column.

# (Array[Integer], Array[Integer], Array[Integer]) -> Hash[Integer, Integer]
def to_lines_map(current_lines, widths, max_word_lengths)
  current_lines.filter.with_index { |_, index| widths[index] > max_word_lengths[index] }
               .map.with_index { |elem, index| [elem, index] }
               .to_h
end

# Find the number of lines in each column of the table.

# (Array[Array[String]], Array[Integer]) -> Array[Integer]
def all_lines(body, widths)
  widths.map.with_index { |width, i| body.map { |row| num_lines(row[i], width) }.sum }
end

# Use hill climbing to find the widths that optimize our heuristic.

# (Array[Array[String]], Array[Integer], Hash[Integer, Integer], Array[Integer]) -> Array[Integer]
def climb_hill(cells, widths, lines_map, max_word_lengths)
  solution_found = false
  until solution_found || lines_map.length < 2
    min = lines_map.keys.min
    max = lines_map.keys.max
    new_widths = adjust_widths(widths, lines_map, min, max)
    test_lines = all_lines(cells, new_widths)
    unless (solution_found = (test_lines[lines_map[max]] <= test_lines[lines_map[min]]))
      widths = new_widths
      current_lines = test_lines
      lines_map = to_lines_map(current_lines, widths, max_word_lengths)
    end
  end
  widths
end

# Adjust the widths of the columns to make the smallest column thinner and the largest column wider.

# (Array[Integer], Hash[Integer, Integer], Integer, Integer) -> Array[Integer]
def adjust_widths(widths, lines_map, min, max)
  new_widths = widths.clone
  new_widths[lines_map[min]] -= 1
  new_widths[lines_map[max]] += 1
  new_widths
end

# Find how many lines each cell in a column takes up.

# (String, Integer) -> Integer
def num_lines(string, width)
  words = string.split(" ")
  lines = 1
  current_width = -1
  until words.empty?
    if current_width + words[0].length + 1 <= width
      current_width += words[0].length + 1
      words = words[1..]
    else
      lines += 1
      current_width = -1
    end
  end
  lines
end

# Check the fitness of widths in the ballpark and return the best one.

# (Array[Array[String]], Array[Integer], Array[Integer]) -> Array[Integer]
def search_better_width(cells, ballpark_center, max_word_lengths)
  # Generate all possible width combinations within the range of the ballpark
  width_offsets = generate_offsets(ballpark_center.length)
  # Filter out invalid width combinations
  width_options = add_valid_offsets(width_offsets, ballpark_center, max_word_lengths)
  # Convert width combinations to a hash mapping the fitness to the array of widths.
  tested = width_options.map { |option| [actual_length(cells, option), option] }
                        .to_h
  tested[tested.keys.min]
end

# Find the actual length of the table given the widths. Unlike the other method, this takes into account the length of
# each column in a given row.

# (Array[Array[String]], Array[Integer]) -> Integer
def actual_length(cells, widths)
  cells.map { |row| row.map.with_index { |cell, i| num_lines(cell, widths[i]) }.max }
       .sum
end

# Generate all possible offsets for the widths

# (Integer) -> Array[Array[Integer]]
def generate_offsets(num_columns)
  range = Math.log(RANDOM_TRIES, num_columns).floor
  (0...num_columns).reduce([[]]) do |width_offsets, _|
    (-range..range).reduce([]) do |new_width_options, i|
      new_width_options += width_offsets.map { |option| option + [i] }
    end
  end
end

# Filter out invalid offsets and add each valid offset to the current widths

# (Array[Array[Integer]], Array[Integer], Array[Integer]) -> Array[Array[Integer]]
def add_valid_offsets(width_offsets, current_widths, max_word_lengths)
  width_offsets.filter { |option| option.sum == 0 }
               .map { |option| option.zip(current_widths).map { |pair| pair.sum } }
               .filter { |option| option.each_with_index.all? { |width, i| width >= max_word_lengths[i] } }
end

# Get the minimum column width that won't make the table longer.

# (Array[Array[String]], Array[Integer], Array[Integer]) -> Array[Integer]
def minimize_widths(cells, current_widths, max_word_lengths)
  (0...current_widths.length).each do |i|
    test_widths = squish_column(current_widths, i)
    while (
      test_widths[i] >= max_word_lengths[i] && actual_length(cells, test_widths) == actual_length(cells, current_widths)
    )
      current_widths = test_widths
      test_widths = squish_column(current_widths, i)
    end
  end
  current_widths
end

# Split a cell into multiple lines of the given width.

# (String, Array[Integer]) -> Array[String]
def split_lines(cell, width)
  words = cell.split(" ")
  current_width = -1
  lines = []
  line = ""
  until words.empty?
    if current_width + words[0].length + 1 <= width
      current_width += words[0].length + 1
      line += "#{words[0]} "
      words = words[1..]
    else
      lines << line[0..-2].ljust(width)
      line = ""
      current_width = -1
    end
  end
  lines << line[0..-2].ljust(width) unless line.empty?
end

# Squish a column by one unit

# (Array[Integer], Integer) -> Array[Integer]
def squish_column(current_widths, column_index)
  new_widths = current_widths.clone
  new_widths[column_index] -= 1
  new_widths
end

# Generate the markdown grid table of cells with the given widths

# (Array[Integer], Array[Array[String]])
def generate_table(widths, cells)
  File.open("out.txt", "w") do |file|
    file.write("+#{widths.map{ |width| '-' * (width + 2) }.join('+')}+\n")
    cells_string = cells.map { |row| row.map.with_index { |cell, i| split_lines(cell, widths[i]) } }
    cells_string[0] = cells_string[0].map.with_index do |arr, i|
      arr.fill(" " * widths[i], arr.length...cells_string[0].map(&:length).max)
    end
    (0...cells_string[0][0].length).each { |i| file.write("| #{cells_string[0].map{ |arr| arr[i] }.join(' | ')} |\n") }
    file.write("+#{widths.map{|width| '=' * (width + 2)}.join('+')}+\n")
    cells_string[1..].each do |row|
      row = row.map.with_index { |arr, i|  arr.fill(" " * widths[i], arr.length...row.map(&:length).max) }
      (0...row[0].length).each { |i| file.write("| #{row.map{|arr| arr[i]}.join(' | ')} |\n") }
      file.write("+#{widths.map{|width| '-' * (width + 2)}.join('+')}+\n")
    end
  end
end

if $PROGRAM_NAME == __FILE__
  cells = get_input
  max_word_lengths = (0...cells[0].length).map { |i| cells.map{ |row| row[i].split(" ").map(&:length).max }.max }
  widths = find_ballpark_widths(cells, max_word_lengths)
  widths = minimize_widths(cells, search_better_width(cells, widths, max_word_lengths), max_word_lengths)
  generate_table(widths, cells)
end
