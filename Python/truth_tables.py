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

# Print truth tables for a boolean expression written in the code.

def two():
    for a in range(2):
        for b in range(2):
            statement1 = (not a or b) and (not a or not b)
            statement2 = not a
            print(a, b, ":", int(statement1), int(statement2))

def three():
    for a in range(2):
        for b in range(2):
            for c in range(2):
                statement1 = a != c
                statement2 = 0
                print(a, b, c, ":", int(statement1), int(statement2))

def four():
    for a in range(2):
        for b in range(2):
            for c in range(2):
                for d in range(2):
                    statement1 = 0
                    statement2 = (not a and b) or (not a and d) or (b and c)
                    print(a, b, c, d, ":", int(statement1), int(statement2))
