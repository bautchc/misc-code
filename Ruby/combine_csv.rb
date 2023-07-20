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

# A simple script that appends one csv file to another.

require 'set' # license: BSD-2-Clause
require 'csv' # license: BSD-2-Clause

# (String, String) -> void
def append_csv(base_path, addendum_path)
  in_base = Set.new
  CSV.foreach(base_path) { |row| in_base << row[0] }
  CSV.open(base_path, 'ab') { |csv| CSV.foreach(addendum_path) { |row| csv << row unless in_base.include?(row[0]) } }
end

append_csv(ARGV[0], ARGV[1]) if __FILE__ == $PROGRAM_NAME
