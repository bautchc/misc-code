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

# Takes a csv containing a list of domains and a list of sitemaps in that domain and adds any missing sitemaps to that
# list.
#
# ARGV[0]: The path to the csv containing the domains. Should be in the following format:
# ignored [siteA.com],any.xml,number.xml,of.xml,sitemaps.xml,
# ignored {siteB.com},trailing.xml,cells.xml,blank.xml,,
#
# ARGV[1]: The output path

require 'csv' # license: BSD-2-Clause
require 'open-uri' # license: BSD-2-Clause
require 'set' # license: BSD-2-Clause

SITEMAP_SUFFIXES = Set[
  '',
  'Articles',
  'Blog',
  'Categories',
  'Gallery',
  'GalleryCommercial',
  'GalleryResidential',
  'Gallerys',
  'IndustriesServed',
  'Manufacturers',
  'Mobile',
  'News',
  'Plants',
  'ProductGallery',
  'Products',
  'Reviews',
  'ServiceArea'
]

# (String) -> Array[String]
def read_csv(csv_path)
  property_names = []
  CSV.foreach(csv_path) do |row|
    # grab the site url
    property_names << row[0].match(/[\[{](.+)[\]}]/)[1].downcase
  rescue NoMethodError
    puts "\e[31mERROR reading #{row[0]}\e[0m"
  end

  property_names
end

# (String) -> bool
def page_exists?(url)
  puts "Looking for: #{url}"
  URI.open(url)
  true
rescue OpenURI::HTTPError
  # if it gets a 404 when it tries to open, it doesn't exist
  #
  # in theory, you should just need to do an http request and read the response code, but I kept getting 301s in place
  # of both 200s and 404s when I tried that. Might be an .xml thing?
  false
end

# (String, Integer, String) -> String
def insert_char(string, back_index, substring)
  "#{string.slice(0, string.length - back_index)}#{substring}#{string.slice(string.length - back_index, string.length)}"
end

# (String, Integer, ?String) -> String
def replace_char(string, back_index, substring = '')
  string.slice(0, string.length - back_index) + substring +
    string.slice(string.length - back_index + 1, string.length)
end

# duplicates can be numbered in the following ways:
# * loremIpsum1, loremIpsum2, loremIpsum2
# * loremIpsum01, loremIpsum02, loremIpsum03
# * loremIpsum, loremIpsum2, loremIpsum3

# (Array[String], String) -> Array[String]
def add_2s(sitemaps, site)
  # normalize by stripping 1s and 01s
  sitemaps_no1 = sitemaps.map do |sitemap|
    if sitemap[-5] == '1'
      sitemap = replace_char(sitemap, 5)
      replace_char(sitemap, 5) if sitemap[-5] == '0'
    else
      sitemap
    end
  end
  sitemaps + sitemaps_no1.map { |sitemap| [insert_char(sitemap, 4, '2'), insert_char(sitemap, 4, '02')] }
                         .flatten
                         .filter { |page| page_exists?("http://www.#{site}#{page}") }
end

# (Array[String], String, Integer) -> Array[String]
def increment_number(sitemaps, site, num)
  sitemaps + sitemaps.filter { |sitemap| sitemap[-5] == num.to_s }
                     .map { |sitemap| replace_char(sitemap, 5, (num + 1).to_s) }
                     .filter { |page| page_exists?("http://www.#{site}#{page}") }
end

# (Array[String], String) -> Array[String]
def test_numbered_sitemaps(sitemaps, site)
  if sitemaps.length == SITEMAP_SUFFIXES.length * 3
    puts "\e[31mImproper 404 for #{site}\e[0m"
    return []
  end
  sitemaps = add_2s(sitemaps, site)
  check = 2
  while sitemaps.any? { |sitemap| sitemap[-5] == check.to_s }
    # if there are any 2s, keep trying higher numbers until there aren't anymore
    sitemaps = increment_number(sitemaps, site, check)
    check += 1
  end
  sitemaps
end

# (String) -> Array[String]
def test_sitemaps(site)
  SITEMAP_SUFFIXES.map { |suffix| [suffix, "#{suffix}1", "#{suffix}01"] }
                  .flatten
                  .map { |suffix| "/sitemap#{suffix}.xml" }
                  .filter { |page| page_exists?("http://www.#{site}#{page}") }
end

# (String) -> Array[String]
def read_robots_txt(site)
  URI.open("http://www.#{site}/robots.txt")
     .read
     .scan(%r{Sitemap: https?://#{site}(/.+)})
     .map { |match| match[0] }
end

# (Array[String]) -> Array[[String, String]]
def find_sitemaps(sites)
  sites.map do |site|
    puts "Checking: #{site}"
    [site, (test_numbered_sitemaps(test_sitemaps(site), site) + read_robots_txt(site)).join(', ')]
  end
end

if __FILE__ == $PROGRAM_NAME
  CSV.open(ARGV[1], 'wb') { |csv| ind_sitemaps(read_csv(ARGV[0])).each { |row| csv << row } }
end
