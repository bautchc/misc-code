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

# A program that takes a csv file of websites and links and generates a batch of color-matched QR codes containing the
# logo of the site (from the highest-quality favicon) in the center.
#
# The script should be run from a folder containing a single .csv file in the following format:
#
# header,is,skipped
# ignored [site1.com],optionalSuffix,https://link.com/lorem
# ignored {site2.com},,https://link.com/ipsum

require 'open-uri' # license: BSD-2-Clause
require 'rqrcode' # license: MIT
require 'chunky_png' # license: MIT
require 'mini_magick' # license: MIT
require 'color_contrast_calc' # license: MIT
require 'csv' # license: BSD-2-Clause

class Business
  # 4 is the minimum specified in ISO standard for QR codes
  CONTRAST_THRESHOLD = 4
  # The ratio between these two should remain constant
  IMAGE_SIZE = 685
  LOGO_SIZE = 180

  # (String, String, String) -> void
  def initialize(name_string, city, review_link)
    regex_match = name_string.match(/[\[{]((.*)\..*)[\]}]/)
    @url = regex_match[1]
    @domain = city ? "#{regex_match[2]}_#{city}" : regex_match[2]
    @link = review_link
    @logo = get_favicon
    @color = @logo ? get_color : nil
  end

  # () -> ChunkyPNG::Image
  def get_favicon
    html = URI.open("http://www.#{@url}").read
    offset = 0
    favicon_url = nil
    custom_image = nil
    ['png', 'jpg|jpeg|jpe|jif|jfif|jfi', 'ico'].each do |image_format|
      next if favicon_url

      begin
        favicon_url = find_image(html, image_format, offset)
        if favicon_url
          favicon_url = URI.join("http://www.#{@url}", favicon_url).to_s unless favicon_url.match?(/www\./)
          custom_image = ChunkyPNG::Image.from_blob(
            if image_format == 'png'
              URI.open(favicon_url, 'rb')
                 .read
            else
              image_blob = MiniMagick::Image.open(URI(favicon_url))
                                            .format('png')
                                            .to_blob
            end
          )
        end
      rescue OpenURI::HTTPError
        # If the favicon it grabs returns a 404, grab the next one
        offset += 1
        retry
      end
    end
    unless favicon_url
      puts "\e[31mCould not scrape logo for #{@domain}\e[0m"
      return nil
    end
    # add a white background to transparent pngs
    ChunkyPNG::Image.new(custom_image.width, custom_image.height, ChunkyPNG::Color::WHITE)
                    .compose(custom_image, 0, 0)
                    .to_blob
  end

  # (String, String, Integer) -> String?
def find_image(html, file_type, offset)
  icon_types = /(?:apple-touch-icon|icon|apple-touch-icon-precomposed|shortcut-icon)/
  # Scrapes the biggest favicon it can find
  regex_matches = html.scan(
    /<link[^>]*?rel=["']#{icon_types}["'][^>]*?sizes="(\d+?)x[^>]*href=["'](.*?\.(?:#{file_type})(?:\?.*?)?)["']/i
  )
                      .sort_by { |size, _link| -size.to_i }
                      .drop(offset)
  if regex_matches.empty?
    regex_matches = html.scan(
      /<link[^>]*?rel=["']#{icon_types}["'][^>]*?href=["'](.*?\.(?:#{file_type})(?:\?.*?)?)["'][^>]*?sizes="(\d+?)x/i
    )
                        .sort_by { |_link, size| -size.to_i }
                        .drop(offset)
    if regex_matches.empty?
      # scrape the first favicon if can't find size info
      regex_matches = html.scan(
                            /<link[^>]*?rel=["']#{icon_types}["'][^>]*?href=["'](.*?\.(?:#{file_type})(?:\?.*?)?)["']/i
                          )
                          .drop(offset)
      if regex_matches.empty?
        regex_matches = html.scan(
                          /<link[^>]*?href=["'](.*?\.(?:#{file_type})(?:\?.*?)?)["'][^>]*?rel=["']#{icon_types}["']/i
                        )
                            .drop(offset)
        if regex_matches.empty?
          nil
        else
          regex_matches[0][0]
        end
      else
        regex_matches[0][0]
      end
    else
      regex_matches[0][0]
    end
  else
    regex_matches[0][1]
  end
end

  # finds the dominant colors and picks the one with the highest contrast
  # if all colors are too low-contrast, default to black

  # () -> String
  def get_color
    color_counts = MiniMagick::Image.read(@logo)
                                    .get_pixels
                                    .flatten(1)
                                    .reduce(Hash.new(0)) { |color_counts, pixel| color_counts[pixel] += 1 }
    color_counts = color_counts.sort_by { |_key, value| -value }
                               .map { |pair| pair[0] }
    dominant_color = color_counts.find do |color|
      ColorContrastCalc.contrast_ratio(color, [255, 255, 255]) > CONTRAST_THRESHOLD
    end
    dominant_color ||= darken_color(color_counts[color_counts[0] == [255, 255, 255] ? 1 : 0])
    # convert color to hex
    dominant_color[0].to_s(16).rjust(2, '0') +
      dominant_color[1].to_s(16).rjust(2, '0') +
      dominant_color[2].to_s(16).rjust(2, '0')
  end

  # ([Integer, Integer, Integer]) -> [Integer, Integer, Integer]
  def darken_color(color)
    hsl_color = ChunkyPNG::Color.to_hsl(ChunkyPNG::Color.rgb(*color))
    until ColorContrastCalc.contrast_ratio(color, [255, 255, 255]) > CONTRAST_THRESHOLD
      hsl_color[2] -= 0.01
      color = ChunkyPNG::Color.to_truecolor_bytes(ChunkyPNG::Color.from_hsl(*hsl_color))
    end
    color
  end

  # () -> ChunkyPNG::Image
  def write_qr_code
    return unless @logo

    png = RQRCode::QRCode.new(@link)
                         .as_png(
                           fill: 'white',
                           color: @color,
                           size: IMAGE_SIZE,
                           file: nil
                         )

    custom_image = ChunkyPNG::Image.from_blob(@logo)
    custom_image = ChunkyPNG::Image.new(custom_image.width, custom_image.height, ChunkyPNG::Color::WHITE)
                                   .compose(custom_image, 0, 0)
                                   .resample_bilinear(LOGO_SIZE, LOGO_SIZE)

    # add logo to center
    png.compose(custom_image, (png.width - custom_image.width) / 2, (png.height - custom_image.height) / 2)
       .save("#{@domain}.png")
  end
end

# (String) -> Arrat[[String, String?, String]]
def read_csv(file_path)
  data = []
  skip_first_row = true
  CSV.foreach(file_path) do |row|
    if skip_first_row
      skip_first_row = false
      next
    end

    data << row.take(3)
  end

  data
end

if __FILE__ == $PROGRAM_NAME
  read_csv(Dir.glob('*.csv')[0]).each do |data|
    next unless data[0]

    puts "Rendering: #{data[0]}"
    Business.new(*data).write_qr_code
  end
end
