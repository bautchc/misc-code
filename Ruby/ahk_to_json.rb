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

# A tool to convert AutoHotkey files that follow my Mugwriter standard into JSON files.

require 'json' # license: BSD-2-Clause

# (String, Hash[String, String|Hash[String, String]], Symbol) -> [Hash[String, String|Hash[String, String]], Symbol]
def parse_header(line, data, section)
  if line.start_with?(/ *;;;/)
    section = :body
  else
    data['_header'] = data['_header'] ? "#{data['_header']}\n#{line}" : line
  end
  [data, section]
end

# (
#   String,
#   Hash[String, String|Hash[String, String]],
#   Symbol,
#   String
# ) -> [Hash[String, String|Hash[String, String]], Symbol, String]
def parse_body(line, data, section, block)
  if line.start_with?(/[^; ]/)
    section = :prepend
  else
    if line.start_with?(/ *;;;/)
      block = line.match(/\A *;;; ?(.*[^ ]) *\z/)[1]
      data[block] = {}
    elsif line.start_with?(/ *;/)
      match = line.match(/\A *; ?(.) (.*[^ ]) *\z/)
      data[block][match[1]] = match[2]
    end
  end
  [data, section, block]
end

# (String, Hash[String, String|Hash[String, String]], Symbol) -> [Hash[String, String|Hash[String, String]], Symbol]
def parse_prepend(line, data, section)
  if section == :prepend
    if line.start_with?(/ *[^; ].*::/)
      section = :end
    else
      data['_prepend'] = data['_prepend'] ? "#{data['_prepend']}\n#{line}" : line
    end
  end
  [data, section]
end

# () -> void
def main
  block = ''
  data = {}
  section = :pre_space
  (ARGV[1] || Dir.glob("*.ahk")[0]).yield_self(&File.method(:foreach)) do |line|
    line.chomp!
    section = :header if section == :pre_space && line !~ /\A *\z/
    data, section = *parse_header(line, data, section) if section == :header
    data, section, block = *parse_body(line, data, section, block) if section == :body
    data, section = *parse_prepend(line, data, section) if section == :prepend
  end

  JSON.pretty_generate(data)
      .yield_self { |json| File.write(ARGV[0] || 'out.json', json) }
end

main if __FILE__ == $PROGRAM_NAME
