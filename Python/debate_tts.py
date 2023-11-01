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

# Generates a number of text-to-speech audio files from the transcript of the 1971 Foucault-Chomsky debate as 
# transcribed at https://chomsky.info/1971xxxx/. Different voices are used for each speaker, and the header naming
# the speaker is maintained. The audio is generated in multiple mp3 files that must be manually concatenated due to
# issues I ran into with mp3 formatting.

# ARGV
# 1 ? Path to transcript file

from os import getcwd, listdir
from sys import argv
import pyttsx3
from gtts import gTTS
from re import search

def main() -> None:
  # Grab first .txt from current directory if no argument is given
  script_path: str = argv[1] if len(argv) > 1 else next((file for file in listdir(getcwd()) if file.endswith('.txt')), None)
  sections: list[str] = read_script(script_path)
  generate_sections(sections)

def read_script(path: str) -> list[str]:
  script: str = ''
  with open(path, 'r', encoding='utf-8') as file: script = file.read()
  return script.split('\n\n\n')

def generate_sections(sections: list[str]) -> None:
  pytts: pyttsx3.Engine = pyttsx3.init()
  voices = pytts.getProperty('voices')

  for i, section in enumerate(sections):
    speaker: str = search(r'^[^:]+:', section).group(0).strip()
    match speaker:
      case 'CHOMSKY:':
        pytts.setProperty('voice', voices[0].id)
        pytts.save_to_file(section, f'section{i:03d}.mp3')
        pytts.runAndWait()
      case 'FOUCAULT:':
        pytts.setProperty('voice', voices[1].id)
        pytts.save_to_file(section, f'section{i:03d}.mp3')
        pytts.runAndWait()
      case _:
        gTTS(text=section, lang='en').save(f'section{i:03d}.mp3')

if __name__ == '__main__': main()
