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

# Takes a list of words and finds all ideal portmanteaus between them, where an ideal portmanteau is defined as as a
# portmanteau where the first word is a one-syllable word that creates the entire first syllable of the portmanteau and
# the second word is the same as the portmanteau but with the first consonant cluster replaced with another consonant
# cluster that has the same primary sound (see rules for primary sounds below).
#
# This program uses the IPA dataset found here: https://github.com/menelik3/cmudict-ipa/blob/master/cmudict-0.7b-ipa.txt
# However, any dataset in the following format will work:
#
# WORD\twɜːd, wɜrd
# EXAMPLE\tɪɡˈzæmpəl
# (where \t is a tab character)
#
# This program uses the frequency dataset found here: https://www.kaggle.com/datasets/rtatman/english-word-frequency
# However, any dataset in the following format will work:
#
# skipped,header
# word,1729
#
# argv[1]: Minimum frequency
# argv[2]: Path to IPA dictionary
# argv[3]: Path to frequency dictionary
# argv[4]: Path to output file

from sys import argv # license: PSF-2.0
from functools import reduce # license: PSF-2.0

letters: set[str] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                     'U', 'V', 'W', 'X', 'Y', 'Z'}
# Other IPA transcriptions of English might need a different vowel list
vow: set[str] = {'æ', 'ɑ', 'ɔ', 'ɪ', 'e', 'ɛ', 'ʌ', 'ʊ', 'ə', 'i', 'u', 'a', 'ɜ', 'o', 'ɝ'}

# Rules for primary sound groups:
#
# Primary sound can be in either the fortis or lenis form.
# Primary sound is the last sound that isn't an approximate or glottal.
# Combinations of approximates and glottals favor the approximate.
# Combinations of a glide and a non-glide approximate favor the non-glide approximate.
# Combinations of non-glide approximates favor the second sound.
# Combinations of glides favor the first sound.
# /h/ on its own is in the same root group as the empty cluster.
alt_sets: list[set[str]] = [
    {'m', 'mj', 'sm', 'dm', 'hm', 'km', 'mw', 'mr', 'ml', 'mh', 'ʃm', 'smr', 'zm'},
    {'n', 'nj', 'sn', 'dn', 'hn', 'kn', 'mn', 'nw', 'fn', 'ʃn', 'wn'},
    {'p', 'b', 'pl', 'bl', 'pr', 'br', 'pw', 'pj', 'bj', 'sp', 'spl', 'spr', 'spj', 'blw', 'bw', 'brw', 'mb', 'sb',
     'zb'},
    {'t', 'd', 'tr', 'dr', 'tw', 'dw', 'tj', 'dj', 'st', 'str', 'dh', 'drw', 'gd', 'ndj', 'nd', 'ʃt', 'stj', 'tl',
     'zdr'},
    {'tʃ', 'dʒ', 'tʃj', 'tʃl', 'tʃr', 'tʃw', 'dʒj', 'dʒf', 'dʒw'},
    {'k', 'g', 'kl', 'gl', 'kr', 'gr', 'gw', 'kw', 'kj', 'gj', 'sk', 'skl', 'skr', 'skw', 'skj', 'lks'},
    {'f', 'v', 'fl', 'fr', 'vw', 'fj', 'vj', 'sf', 'dv', 'fw', 'kv', 'sv', 'ʃv', 'tv', 'vl', 'vr', 'zv'},
    {'θ', 'ð', 'θr', 'θw', 'θj', 'fθ', 'ðj'},
    {'s', 'z', 'sl', 'sw', 'sj', 'zj', 'ts', 'dz', 'fs', 'ksj', 'sh', 'sr', 'tsj', 'zl', 'zw'},
    {'ʃ', 'ʒ', 'ʃl', 'ʃr', 'ʃw', 'ʃj', 'ʒw', 'pʃ'},
    {'h', ''},
    {'l', 'lj', 'hl', 'lhj', 'lw'},
    {'r', 'hr', 'rw', 'rj'},
    {'j', 'hj', 'jw'},
    {'w', 'hw'},
]
# Unusual clusters in the above list come from loan words and proper nouns included in the dataset used. A dataset with
# even more loan words and proper nouns might need a more extensive list of sets.

# A dict that matches each possible consonant cluster to the set of other consonant clusters in the same group for fast
# lookup
alt_dict: dict[str, set[str]] = dict(
    reduce(lambda full, set: full + [(sound, set - {sound}) for sound in set], alt_sets, [])
)

def main() -> None: write_ports(read_sound_list(read_freq_list(argv[3], argv[1]), argv[2]), argv[4])

def read_freq_list(path: str, min_freq: int) -> set[str]:
    all_words: set = set()
    with open(path, 'r') as file:
        # Skip header
        file.readline()
        pop: int = min_freq + 1
        line: str = None
        while pop > min_freq and line != ['']:
            line = file.readline() \
                       .strip() \
                       .split(',')
            if len(line) > 1:
                all_words.add(line[0])
                pop = int(line[1])

    return all_words

def read_sound_list(all_words: set[str], path: str) -> dict[str, set[str]]:
    all_sounds: dict[str, list[str]] = {}
    with open(path, 'r', encoding='utf-8') as file:
        for line in file:
            if line[0] in letters:
                [word, sounds] = line.strip() \
                                     .split('\t')
                if word.lower() in all_words:
                    # Stress markers and long vowel marker not considered significant enough to be distinguished
                    for sound in map(
                        lambda sound: sound.replace('ˌ', '')
                                           .replace('ˈ', '')
                                           .replace('ː', ''),
                        sounds.split(', ')
                    ):
                        if sound not in all_sounds: all_sounds[sound] = []
                        all_sounds[sound].append(word)

    return all_sounds

def write_ports(all_sounds: dict[str, list[str]], path: str) -> None:
    with open(path, 'w') as writer:
        file = ''
        for sound in all_sounds.keys():
            true_const: str = find_const(sound)
            main: str = find_main(sound)
            if true_const != main:
                for const in alt_dict[true_const]:
                    alt_main: str = const + main[len(true_const):]
                    for i in range(len(const), len(alt_main) + 1):
                        first_word: str = alt_main[:len(alt_main) - i + len(const)]
                        if first_word in all_sounds:
                            for sound1 in all_sounds[first_word]:
                                for sound2 in all_sounds[sound]:
                                    file += f'{sound1} + {sound2}\n'
        # All lines written at once for slight speed improvement
        writer.write(file)

# Absence of vowel sounds not handled
def find_const(word: str, index: int=0) -> str:
    return (word[:index] if (word[index] in vow) else find_const(word, index + 1))

def find_main(word: str, index: int=-1) -> str:
    if word[index] in vow and (index == -len(word) or word[index - 1] not in vow):
        return word[:index]
    else:
        return find_const(word, index - 1)

if __name__ == '__main__': main()
