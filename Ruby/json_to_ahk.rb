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

# A tool to generate Mugwriter AutoHotkey files from JSON files.

require 'json' # license: BSD-2-Clause

SHIFT_MAP = {
  '~' => '+`',
  '!' => '+1',
  '@' => '+2',
  '#' => '+3',
  '$' => '+4',
  '%' => '+5',
  '^' => '+6',
  '&' => '+7',
  '*' => '+8',
  '(' => '+9',
  ')' => '+0',
  '_' => '+-',
  '+' => '+=',
  'Q' => '+q',
  'W' => '+w',
  'E' => '+e',
  'R' => '+r',
  'T' => '+t',
  'Y' => '+y',
  'U' => '+u',
  'I' => '+i',
  'O' => '+o',
  'P' => '+p',
  '{' => '+[',
  '}' => '+]',
  '|' => '+\\',
  'A' => '+a',
  'S' => '+s',
  'D' => '+d',
  'F' => '+f',
  'G' => '+g',
  'H' => '+h',
  'J' => '+j',
  'K' => '+k',
  'L' => '+l',
  ':' => '+;',
  '"' => '+\'',
  'Z' => '+z',
  'X' => '+x',
  'C' => '+c',
  'V' => '+v',
  'B' => '+b',
  'N' => '+n',
  'M' => '+m',
  '<' => '+,',
  '>' => '+.',
  '?' => '+/'
}.tap { |shift_map| shift_map.default_proc = Proc.new { |hash, key| hash[key] = key } }

SPECIAL_CHARACTERS = {' ' => 'Space'}.tap do |special_characters|
  special_characters.default_proc = Proc.new { |hash, key| hash[key] = key }
end

# (Hash[String, Hash[String, String]]) -> Array[String]
def generate_ahk_body(inverted_json)
  inverted_json.map do |key, block|
    "!#{SHIFT_MAP[SPECIAL_CHARACTERS[key]]}:: {\n  " \
    + block.dup
           .tap { |block| block.delete('_default') }
           .map do |mode, value|
             "if (mode = '#{mode}')\n" \
             + "    #{value.length == 1 ? "Send '#{value}'" : "#{value}"}\n" \
             + "  else"
           end
           .join(' ')
           .yield_self do |paragraph|
             if block['_default']
               (paragraph.empty? ? '' : "#{paragraph}\n    ") \
               + (block['_default'].length == 1 ? "Send '#{block['_default']}'" : "#{block['_default']}")
             else
               paragraph[...-7]
             end
           end \
    + "\n}"
  end
end

# (Hash[String, Hash[String, String]]) -> Array[String]
def generate_plus_body(inverted_json)
  inverted_json.map do |key, block|
    "#{SHIFT_MAP[SPECIAL_CHARACTERS[key]]}:: {\n  " \
    + block.dup.tap { |block| block.delete('_default') }
           .map do |mode, value|
             "if (mode = '#{mode}_Plus')\n" \
             + "    #{value.length == 1 ? "Send '#{value}'" : "#{value}"}\n" \
             + "  else" \
           end
           .join(' ')
           .yield_self { |block| "#{block}\n    Send '#{key}'" } \
    + "\n}"
  end
end

# (Hash[String, Hash[String, String]]) -> Hash[String, Hash[String, String]]
def invert_json(json)
  json.dup
      .tap { |json| json['_menuPlus'] = json['_menu'].map { |key, option| [key, "#{option}_Plus"] }.to_h }
      .reduce(Hash.new { |hash, key| hash[key] = {} }) do |hash, (header, block)|
        block.reduce(hash) { |hash, (key, value)| hash.tap { |hash| hash[key][header] = value } }
      end
end

# () -> void
def main
  json = (ARGV[1] || Dir.glob("*.ahk")[0]).yield_self(&File.method(:read))
                                          .yield_self(&JSON.method(:parse))
  prepend = json.delete('_prepend')
  header = json.delete('_header')
  inverted_json = invert_json(json)

  File.open(ARGV[0] || 'out.ahk', 'w') do |file|
    (
      header ? [header] : [] \
      + json.map { |header, block| ";;; #{header}\n#{block.map { |key, value| "; #{key} #{value}"}.join("\n")}" } \
      + (prepend ? [prepend] : []) \
      + ['mode := _default'] \
      + generate_ahk_body(inverted_json) \
      + generate_plus_body(inverted_json)
    ).join("\n\n")
     .yield_self(&file.method(:write))
  end
end

main if __FILE__ == $PROGRAM_NAME

