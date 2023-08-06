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

# Several methods for calculating the nth Catalan number.

import math


def get_total_for_n(n):
    total = 0
    if n == 0:
        return 1
    for permutation_list in get_permutation_lists(n):
        add = 1
        for box in permutation_list:
            add *= get_total_for_n(box - 1)
        total += add
    return int(total)


def get_permutation_lists(n):
    lists = []
    if n == 0:
        return [[]]
    for i in range(1, n + 1):
        new_list = [i]
        append_lists = get_permutation_lists(n - i)
        for append_list in append_lists:
            lists.append(new_list + append_list)
    return lists


print("BOXES METHOD")
print(get_total_for_n(1))
print(get_total_for_n(2))
print(get_total_for_n(3))
print(get_total_for_n(4))
print(get_total_for_n(5))
print(get_total_for_n(6))


def get_paths_for_n(n):
    return get_paths_for_n_recursive(n, n, 0)


def get_paths_for_n_recursive(plus, minus, height):
    total = 0
    if plus > 0:
        total += get_paths_for_n_recursive(plus - 1, minus, height + 1)
    if minus > 0 and height > 0:
        total += get_paths_for_n_recursive(plus, minus - 1, height - 1)
    return total


print("BRUTE FORCE METHOD")
print(get_total_for_n(1))
print(get_total_for_n(2))
print(get_total_for_n(3))
print(get_total_for_n(4))
print(get_total_for_n(5))
print(get_total_for_n(6))


def summation_equation(n):
    print(1)
    sums = [1, 1]
    for i in range(2, n + 1):
        sum = math.factorial(2 * i) // (math.factorial(i) ** 2)
        for j in range(1, i + 1):
            sum -= sums[i - j] * (math.factorial(2 * j - 1) // (math.factorial(j) * math.factorial(j - 1)))
        print(sum)
        sums.append(sum)

