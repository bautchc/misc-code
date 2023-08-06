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

# A script I use to convert my custom Toki Pona markdown flavor into LaTeX. It's somewhat hacky, but it gets the job
# done. To make things easier on myself, I've been slowly adding onto it as I come across new things that it can't fully
# handle, so this version is incomplete and will be slowly updated from time to time.
#
# ARGV[0]: path to the markdown file containing the unprocessed text.

# Toki Pona words and their Unicode codepoints. The codepoints for non-compound glyphs and some of the symbols follow
# this UCSUR standard: https://www.kreativekorp.com/ucsur/charts/sitelen.html. The rest are somewhat arbitrarily
# assigned to slot into my custom OpenType font.
WORD_CONVERSIONS = {
  'kijetesantakalu' => "\u{F1980}",
  'sitelen-namako' => "\u{F6078}",
  'kulupu-kipisi' => "\u{F1F7B}",
  'sitelen-pona' => "\u{F6054}",
  'sijelo-pali' => "\u{F5B49}",
  'kulupu-pana' => "\u{F7B4C}",
  'kipisi-lipu' => "\u{F1F2A}",
  'nasin-nanpa' => "\u{F3F3D}",
  'sitelen-ali' => "\u{F6004}",
  'sitelen-ala' => "\u{F6002}",
  'sitelen-ike' => "\u{F600D}",
  'kipisi-mute' => "\u{F1F3C}",
  'open-lukin' => "\u{F472E}",
  'lukin-open' => "\u{F2E47}",
  'kepeken \(' => "\u{F0019}(",
  'kulupu-tan' => "\u{F4C67}",
  'pali-nanpa' => "\u{F493D}",
  'nanpa-ante' => "\u{F3D06}",
  'nasin-pana' => "\u{F3F4C}",
  'nanpa-mute' => "\u{F3D3C}",
  'ante-tenpo' => "\u{F066B}",
  'nasin-ni-m' => "\u{F3F41}",
  'ante-nanpa' => "\u{F063D}",
  'nanpa-luka' => "\u{F3D2D}",
  'lipu-nanpa' => "\u{F2A3D}",
  'kipisi-ala' => "\u{F7B02}",
  'lipu-open' => "\u{F2A47}",
  'toki-seme' => "\u{F6C59}",
  'nimi-pali' => "\u{F4249}",
  'nimi-open' => "\u{F4247}",
  'nanpa-wan' => "\u{F3D73}",
  'ilo-nanpa' => "\u{F0E3D}",
  'pali-ni-s' => "\u{F4941}",
  'pali-ni-m' => "\u{F0949}",
  'pali-ante' => "\u{F4906}",
  'nanpa-tu' => "\u{F3D6E}",
  'nimi-tan' => "\u{F4267}",
  'pi-nanpa' => "\u{F4D3D}",
  'pini-ala' => "\u{F5002}",
  'ijo-pana' => "\u{F0C4C}",
  'misikeke' => "\u{F1987}",
  'kokosila' => "\u{F1984}",
  'tan-ni-m' => "\u{F6741}",
  'tan-mute' => "\u{F673C}",
  'pana-wan' => "\u{F4C73}",
  'pana-ala' => "\u{F4C02}",
  'ilo-ante' => "\u{F0E06}",
  'ilo-toki' => "\u{F0E6C}",
  'pi-lipu' => "\u{F4D2A}",
  'pi-ante' => "\u{F4D06}",
  'lipu-ni' => "\u{F2A41}",
  'tawa \(' => "\u{F0069}(",
  'tu\+wan' => "\u{F6E73}",
  'ijo-tan' => "\u{F0C67}",
  'tan-ala' => "\u{F6702}",
  'kepeken' => "\u{F1919}",
  'sitelen' => "\u{F1960}",
  'monsuta' => "\u{F197D}",
  'tenpo_' => "\u{F006B}",
  'lon \(' => "\u{F002C}(",
  'tu\+tu' => "\u{F6E6E}",
  'pi-ilo' => "\u{F4D0E}",
  'nanpa_' => "\u{F003D}",
  'tan \(' => "\u{F0067}(",
  'lanpan' => "\u{F1985}",
  'kalama' => "\u{F1915}",
  'kulupu' => "\u{F191F}",
  'pakala' => "\u{F1948}",
  'palisa' => "\u{F194A}",
  'pimeja' => "\u{F194F}",
  'sijelo' => "\u{F195B}",
  'sinpin' => "\u{F195F}",
  'soweli' => "\u{F1962}",
  'majuna' => "\u{F19A2}",
  'namako' => "\u{F1978}",
  'kipisi' => "\u{F197B}",
  'jasima' => "\u{F197F}",
  'jo-ala' => "\u{F1302}",
  'pi \(' => "\u{F1993}(",
  '\) la' => ")\u{F0021}",
  '\(ala' => "(\u{F0902}",
  'luka_' => "\u{F002D}",
  'ante_' => "\u{F0006}",
  'wile-' => "\u{F0077}",
  'sona-' => "\u{F0061}",
  'akesi' => "\u{F1901}",
  'apeja' => "\u{F19A1}",
  'kiwen' => "\u{F191B}",
  'linja' => "\u{F1929}",
  'lukin' => "\u{F192E}",
  'monsi' => "\u{F1938}",
  'nanpa' => "\u{F193D}",
  'nasin' => "\u{F193F}",
  'pilin' => "\u{F194E}",
  'tenpo' => "\u{F196B}",
  'utala' => "\u{F1971}",
  'tonsi' => "\u{F197E}",
  'epiku' => "\u{F1983}",
  'alasa' => "\u{F1903}",
  'ni-m' => "\u{F4138}",
  'ken-' => "\u{F0018}",
  '-ala' => "\u{F0002}",
  'ni-s' => "\u{F415F}",
  'ala-' => "\u{F0902}",
  'wan_' => "\u{F0073}",
  'insa' => "\u{F190F}",
  'jaki' => "\u{F1910}",
  'jelo' => "\u{F1912}",
  'kala' => "\u{F1914}",
  'kama' => "\u{F1916}",
  'kasi' => "\u{F1917}",
  'kili' => "\u{F191A}",
  'kule' => "\u{F191E}",
  'kute' => "\u{F1920}",
  'lape' => "\u{F1922}",
  'laso' => "\u{F1923}",
  'lawa' => "\u{F1924}",
  'lete' => "\u{F1926}",
  'lili' => "\u{F1928}",
  'lipu' => "\u{F192A}",
  'loje' => "\u{F192B}",
  'luka' => "\u{F192D}",
  'lupa' => "\u{F192F}",
  'mama' => "\u{F1931}",
  'mani' => "\u{F1932}",
  'mije' => "\u{F1935}",
  'moku' => "\u{F1936}",
  'moli' => "\u{F1937}",
  'musi' => "\u{F193B}",
  'mute' => "\u{F193C}",
  'nasa' => "\u{F193E}",
  'nena' => "\u{F1940}",
  'nimi' => "\u{F1942}",
  'noka' => "\u{F1943}",
  'olin' => "\u{F1945}",
  'open' => "\u{F1947}",
  'pake' => "\u{F19A0}",
  'pali' => "\u{F1949}",
  'pana' => "\u{F194C}",
  'pini' => "\u{F1950}",
  'pipi' => "\u{F1951}",
  'poka' => "\u{F1952}",
  'poki' => "\u{F1953}",
  'pona' => "\u{F1954}",
  'powe' => "\u{F19A3}",
  'sama' => "\u{F1956}",
  'seli' => "\u{F1957}",
  'selo' => "\u{F1958}",
  'seme' => "\u{F1959}",
  'sewi' => "\u{F195A}",
  'sike' => "\u{F195C}",
  'sina' => "\u{F195E}",
  'sona' => "\u{F1961}",
  'suli' => "\u{F1963}",
  'suno' => "\u{F1964}",
  'supa' => "\u{F1965}",
  'suwi' => "\u{F1966}",
  'taso' => "\u{F1968}",
  'tawa' => "\u{F1969}",
  'telo' => "\u{F196A}",
  'toki' => "\u{F196C}",
  'tomo' => "\u{F196D}",
  'unpa' => "\u{F196F}",
  'walo' => "\u{F1972}",
  'waso' => "\u{F1974}",
  'wawa' => "\u{F1975}",
  'weka' => "\u{F1976}",
  'wile' => "\u{F1977}",
  'leko' => "\u{F197C}",
  'soko' => "\u{F1981}",
  'meso' => "\u{F1982}",
  'meli' => "\u{F1933}",
  'anpa' => "\u{F1905}",
  'ante' => "\u{F1906}",
  'awen' => "\u{F1908}",
  'esun' => "\u{F190B}",
  'ilo' => "\u{F190E}",
  'jan' => "\u{F1911}",
  'ken' => "\u{F1918}",
  'kon' => "\u{F191D}",
  'len' => "\u{F1925}",
  'lon' => "\u{F192C}",
  'mun' => "\u{F193A}",
  'ona' => "\u{F1946}",
  'pan' => "\u{F194B}",
  'sin' => "\u{F195D}",
  'tan' => "\u{F1967}",
  'uta' => "\u{F1970}",
  'wan' => "\u{F1973}",
  'kin' => "\u{F1979}",
  'oko' => "\u{F197A}",
  'ike' => "\u{F190D}",
  'ala' => "\u{F1902}",
  'ale' => "\u{F1904}",
  'ali' => "\u{F1904}",
  'anu' => "\u{F1907}",
  'ijo' => "\u{F190C}",
  'tu_' => "\u{F006E}",
  'jo' => "\u{F1913}",
  'ko' => "\u{F191C}",
  'la' => "\u{F1921}",
  'li' => "\u{F1927}",
  'ma' => "\u{F1930}",
  'mi' => "\u{F1934}",
  'mu' => "\u{F1939}",
  'ni' => "\u{F1941}",
  'pi' => "\u{F194D}",
  'pu' => "\u{F1955}",
  'tu' => "\u{F196E}",
  'ku' => "\u{F1988}",
  'en' => "\u{F190A}",
  'o' => "\u{F1944}",
  'n' => "\u{F1986}",
  'a' => "\u{F1900}",
  'e' => "\u{F1909}"
}

# (String) -> String
def convert_to_latex(content)
  # Escape content inside of codeblocks
  content.scan(/^```$(.*?)^```$/m).flatten.each do |match|
    content.gsub!(match, match.gsub(/^.+$/, '$\0$'))
  end
  # Escape content inside of inline code
  content.gsub!(/(?<!`)`[^`]+`/, '$\0$')

  # Format nested long pi
  regex = /pi <([^> ]+) ([^>]+)> ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
  content.sub!(regex, 'pi-\1<\2>\3') while content =~ regex
  regex = /<([^ >]+)(?: ([^>]+))?> ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
  content.sub!(regex, '\1_ <\2>\3') while content =~ regex
  content.gsub!('<>', '')

  # Escape text inside cartouche
  content.gsub!(/\[[^\]]*\]/, '$\0$')

  # Convert words to unicode
  WORD_CONVERSIONS.each do |word, unicode|
    regex = /#{word} ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
    content.sub!(regex, "#{unicode}\\1") while content =~ regex
  end

  # Unescape cartouche content
  content.gsub!(/\$(\[[^\]]*\])\$/, '\1')

  # Process escaped periods
  regex = /\\\. ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
  content.sub!(regex, "\u{2024}\\1") while content =~ regex

  # Format cartouche
  content.gsub!(/\[([^\]]*)\] ?/, "\u{F1990}\\dunderline{0.1em}{\\textoverline{0.1em}{\\1}}\u{F1991}")

  # Directionalize quotes
  regex = /"([^"]*)" ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
  content.sub!(regex, "\u{201C}\\1\u{201D}\\2") while content =~ regex

  # Format long characters
  regex = /\(([^)]*)\) ?([^$]*+(?>\$[^$]*\$[^$]*)*$)/
  content.sub!(regex, "\u{F1997}\\dunderline{0.1em}{\\1}\u{F1998}\\2") while content =~ regex

  # Chomp extra whitespace
  content.gsub!(/(?<![.:]) ?(\$[^$]+\$) ?/, '\1')

  prepend = "\\documentclass[letterpaper]{book}

    \\usepackage[margin=1in]{geometry}
    \\usepackage{fontspec}
    \\usepackage{titletoc}
    \\usepackage{titlesec}
    \\usepackage{graphicx}

    \\setmainfont{nasin-nanpa}
    \\setlength{\\parskip}{10pt}
    \\setlength{\\parindent}{0pt}
    \\renewcommand{\\contentsname}{\u{F191F}\u{F1993}\\dunderline{0.1em}{\u{F1F2A}}\u{F1998}}
    \\titleformat{\\chapter}[display]{\\normalfont\\bfseries}{}{0pt}{\\Huge}
    \\renewcommand\\chaptermark[1]{\\markboth{#1}{}}

    \\newcommand\\dunderline[3][-0.1em]{{\\sbox0{#3}\\ooalign{\\copy0\\cr\\rule[\\dimexpr#1-#2\\relax]{\\wd0}{#2}}}}
    \\newcommand\\textoverline[3][1em]{{\\sbox0{#3}\\ooalign{\\copy0\\cr\\rule[\\dimexpr#1-#2\\relax]{\\wd0}{#2}}}}
    \\newcommand{\\thickhrulefill}{\\vspace{-1.5em}\\leavevmode\\leaders\\hrule height 1pt\\hfill\\kern 0pt}

    \\begin{document}
	  \\sloppy
    \\raggedright
    \\frontmatter

    \\thispagestyle{empty}
    \\begin{center}
     \\vspace*{2cm}
     {\\Huge\\bfseries "

  end_header = '\par}
    \end{center}
    \newpage

    \thispagestyle{empty}
    \begin{center}
      \vspace{2cm}'

  end_title_page = '\end{center}
    \newpage

    \titlecontents{chapter}[0pt]{\addvspace{1em}}{}{}{\titlerule*[1pc]{.}\contentspage}
    \tableofcontents
    \mainmatter
  '

  # Format cover, title page and table of contents
  content.sub!(/# (.*)/, "#{prepend}\\1#{end_header}")
  content.sub!(/(## )/, "#{end_title_page}\\1")

  # Format chapters
  content.gsub!(/## (.*)/, '\chapter{\1}')

  # Format code blocks
  content.scan(/^```$(.*?)^```$/m).flatten.each do |match|
    content.gsub!(match, match.gsub(/^\$(.+)\$$/)) do
      "\\texttt{#{Regexp.last_match(1).gsub(/[ #_{}]/, '\\\0')}}\n"
    end
  end
  content.gsub!(/^```$(.*?)^```$/m) do
    "\\thickhrulefill\n{\\setlength{\\parskip}{0pt}\n\n\n#{
                                                            Regexp.last_match(1)
                                                                  .gsub(/(\r?\n){3}/, "\n\n\\vspace{1em}\n\n")
                                                          }\n}\\thickhrulefill"
  end

  # Format inline code
  content.gsub!(/\$`([^`]+)`\$/) do
    "\\raisebox{0.15em}{\\scalebox{0.85}{\\texttt{#{Regexp.last_match(1).gsub(/[#_{}]/, '\\\0')}}}}"
  end

  # Format math
  content.gsub!(/\$([^$]+)\$/, '\raisebox{0.15em}{\scalebox{0.85}{$\,\1\,$}}')

  content + "\n\\end{document}"
end

File.write(ARGV[0].gsub('.md', '.tex'), convert_to_latex(File.read(ARGV[0]))) if __FILE__ == $PROGRAM_NAME
