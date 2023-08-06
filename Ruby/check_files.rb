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

# Gets a csv contains a list of file names and the folder they're apart of and checks whether that file exists
#
# Should be in a folder containing a single csv file in the following format:
# header,is,skipped
# ignored [file1],,folder1
# ignored {file2},,folder2
#
# ARGV[0]: The directory containing the folders

require 'csv' # license: BSD-2-Clause

# (String, String) -> void
def update_csv(csv_path, file_directory)
  table = CSV.table(csv_path)

  current_team = nil
  current_folder = nil
  # Go through each project in the csv and find the files associated with it
  table.each do |row|
    file_status = ''
    # If it reaches another team, switch to that team's folder
    unless current_team == row[2]
      current_team = row[2]
      puts current_folder.inspect
      current_folder = Dir.glob('*', base: "#{file_directory}\\___#{current_team}")
    end
    # Find the files associated with the current project
    matches = current_folder.filter do |file_name|
      # Find the project name from the first column enclosed in {} or []
      file_name.start_with?(row[0].match(/(?<=[{\[])[^\]}]*(?=[}\]])/)[0])
    end
    current_folder -= matches
    row['One File?'] = case matches.size
                       when 0
                         'No File'
                       when 1
                         'OK'
                       else
                         # .bak files are automatically created backups
                         if matches.size == 2 && matches.select { |file_name| file_name.end_with?('.bak') }
                           'Backup'
                         else
                           'Extra'
                         end
                       end
  end
  puts current_folder.inspect

  CSV.open(csv_path, 'w') do |f|
    f << table.headers
    table.each { |row| f << row }
  end
end

update_csv(Dir.glob('*.csv')[0], ARGV[0]) if __FILE__ == $PROGRAM_NAME
