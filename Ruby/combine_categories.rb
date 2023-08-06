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

# Takes the information from two csv files and combines them into one csv file.
#
# ARGV[0]: Path to products csv file
# ARGV[1]: Path to categories csv file
# ARGV[2]: Path to output csv file

require 'csv' # license: BSD-2-Clause

# (String, String) -> [CSV::Table, Hash[Integer, Array[Integer]]]
def read_csv(categories_path, products_path)
  categories_hash = Hash.new { |hash, key| hash[key] = [] }
  skip_flag = true
  categoryids_index = nil
  stockstatus_index = nil
  # CSV::Table isn't used for this because the efficiency loss is non-trivial for a sheet of this size
  CSV.foreach(products_path) do |row|
    if skip_flag
      skip_flag = false
      categoryids_index = row.index('categoryids')
      stockstatus_index = row.index('stockstatus')
      next
    end
    next unless row[categoryids_index]
    # categoryids is a string of concatinated 4-digit numbers with improperly placed commas
    row[categoryids_index].gsub(',', '')
                          .chars
                          .each_slice(4)
                          .map { |id| id.join.to_i }
                          .each { |id| categories_hash[id] << row[stockstatus_index].to_i }
  end

  [CSV.table(categories_path), categories_hash]
end

# (CSV::Table, Hash[Integer, Array[Integer]]) -> CSV::Table
def generate_csv(categories_table, categories_hash)
  base_columns = %w[categoryid parentid categoryname rootid breadcrumb]
  categories_table.headers.each { |column| categories_table.delete(column) unless base_columns.include?(column.to_s) }

  categories_table = append_table(categories_table, categories_hash)

  categories_table
end

# (CSV::Table, Hash[Integer, Array[Integer]]) -> CSV::Table
def append_table(table, categories_hash)
  table.each do |row|
    row[:Parent_Category_Id] = unless row[:parentid] == '0'
                                 table.find { |inner_row| inner_row[:categoryid] == row[:parentid] }
                                     &.[](:categoryname)
                               end
    row[:category_visible_root_name] = row[:Parent_Category_Id] || row[:categoryname]
    row[:category_product_count] = categories_hash[row[:categoryid].to_i].length
    row[:category_product_sum] = categories_hash[row[:categoryid].to_i].sum
  end

  table
end

# (CSV::Table, String) -> void
def write_csv(data, output_path)
  CSV.open(output_path, 'w') do |file|
    file << data.headers
    data.each { |row| file << row }
  end
end

write_csv(generate_csv(*read_csv(ARGV[0], ARGV[1])), ARGV[2]) if __FILE__ == $PROGRAM_NAME
