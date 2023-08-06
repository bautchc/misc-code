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

# Takes a csv containing a list of domains and checks whether they have a review schema
#
# ARVG[0]: The path to the csv containing the domains. Should be in the following format:
# skippedHeader
# ignored [domain.com]
# ignored {domain2.com}
#
# ARGV[1]: The output path

require 'csv' # license: BSD-2-Clause
require 'open-uri' # license: BSD-2-Clause

# (String, String) -> void
def write_csv(input_path, output_path)
  # Takes in a csv such that the first column contains a domain in [] or {}
  title = nil
  data = []
  first_row = true

  CSV.open(output_path, 'wb') do |csv|
    CSV.foreach(input_path) do |row|
      if first_row
        csv << row.append('HAS REVIEW SCHEMA?')
        first_row = false
      else
        # skip empty rows
        next unless row[0]

        puts "Checking: #{row[0]}"
        # use domain inside [] or {}
        begin
          csv << row.append(
            URI.open("http://www.#{row[0].match(/[\[{](.*)[\]}]/)[1]}")
               .read
               .match?(%r{"@context" ?: ?"https?://(?:www\.)?schema\.org})
          )
        rescue OpenURI::HTTPError
          puts "\e[31mERROR: #{row[0]}\e[0m"
          csv << row.append('ERROR')
        end
      end
    end
  end
end

write_csv(ARGV[0], ARGV[1]) if __FILE__ == $PROGRAM_NAME
