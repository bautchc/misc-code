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

# Takes the data from several json files in the format retrieved from Google's My Business API and formats it into a
# csv.
#
# Input json files should have data in the following format:
# {
#   locations: Array[{
#     categories: {
#       primaryCategory: {
#         displayName: String
#       }
#     },
#     metadata: {
#       mapsUri: String
#     },
#     name: String,
#     websiteUri: String?,
#     additionalCategories: Array[{
#       displayName: String
#     }]?
#   }]
# }
#
# ARGV[0] csv containing a list of sites to be included in the csv. Site names should be in the first column, enclosed
#         by [] or {} with any other text outside of it.
# ARGV[1] Name of the csv to be created.

require 'csv' # license: BSD-2-Clause
require 'json' # license: BSD-2-Clause

# Maps a uri to a different uri. Must be manually updated.
ALIASES = {}

# (String) -> Hash[String, {name: String, visited: false}]
def get_property_names(property_names_path)
  property_names = {}
  CSV.foreach(property_names_path) do |row|
    property_names[row[0].match(/[\[{](.+)[\]}]/)[1].downcase] = { name: row[0], visited: false }
  rescue NoMethodError
    puts "\e[31mERROR reading #{row[0]}\e[0m"
  end

  property_names
end

# (String, String, Hash[String, {name: String, visited: bool}]) -> void
def append_csv!(json_path, output_path, property_names)
  team = json_path.match(/(.+)\.json$/)[1]
  data = JSON.parse(File.read(json_path), { symbolize_names: true })
  CSV.open(output_path, 'ab') do |csv|
    data[:locations].each { |location| add_row!(csv, location, team, property_names) }
  end
end

# (
#   CSV,
#  {
#    categories: {primaryCategory: {displayName: String}},
#    metadata: {mapsUri: String},
#    name: String,
#    websiteUri: String?,
#    additionalCategories: Array[{displayName: String}]?
#  },
#  String,
#  Hash[String, {name: String, visited: bool}]
# ) -> void
def add_row!(csv, location, team, property_names)
  uri = location[:websiteUri]&.match(%r{/(?:www\.)?([^/]+)})&.[](1)
  uri = ALIASES[uri] if ALIASES.has_key?(uri)
  if (in_list = property_names.has_key?(uri))
    property_names[uri][:visited] = true
  else
    puts "#{uri} not in property list"
    return if uri
  end
  csv << [
    in_list ? property_names[uri][:name] : uri,
    location[:categories][:primaryCategory][:displayName],
    location[:categories][:additionalCategories]&.map { |category| category[:displayName] }&.join(', '),
    team,
    location[:metadata][:mapsUri],
    location[:name].match(%r{locations/(.+)})[1]
  ]
end

if __FILE__ == $PROGRAM_NAME
  property_names = get_property_names(ARGV[0])
  File.delete(ARGV[1])
  Dir.glob('*.json')
     .each { |json_path| append_csv!(json_path, ARGV[1], property_names) }
  property_names.values
                .filter { |value| !value[:visited] }
                .map { |value| value[:name] }
                .each { |property| puts "No data found for #{property}" }
end
