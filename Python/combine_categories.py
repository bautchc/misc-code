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

# Takes the information from two csv files and combines them into one csv file.
#
# argv[1]: Path to products csv file
# argv[2]: Path to categories csv file
# argv[3]: Path to output csv file

import csv # license: PSF-2.0
import sys # license: PSF-2.0

def read_csv(products_path: str) -> dict[str, list[int]]:
    categories_hash = {}
    with open(products_path) as csv_file:
        for row in csv.DictReader(csv_file):
            if not row['categoryids'] == '' and not row['stockstatus'] == '':
                # stock status is a string of concatinated 4-digit numbers that's improperly formatted with commas added
                chars = [ch for ch in row['categoryids'] if ch != ',']
                for i in range(0, len(chars), 4):
                    id = ''.join(chars[i:i + 4])
                    if not categories_hash.get(id):
                        categories_hash[id] = []
                    categories_hash[id].append(int(row['stockstatus']))

    return categories_hash

def generate_csv(
  categories_table: list[dict[str, str]],
  categories_hash: dict[str, list[int]],
  output_path: str
) -> None:
    base_columns = ['categoryid', 'parentid', 'categoryname', 'rootid', 'breadcrumb']
    writer = csv.DictWriter(
      open(output_path, 'w', newline=''),
      fieldnames=base_columns + [
        'Parent_Category_Id',
        'category_visible_root_name',
        'category_product_count',
        'category_product_sum'
      ]
    )
    writer.writeheader()

    name_hash = {}
    for row in categories_table: name_hash[row['categoryid']] = row['categoryname']

    for row in categories_table:
        new_row = {}
        for key in row:
            if key in base_columns: new_row[key] = row[key]

        if not name_hash.get(new_row['parentid']): new_row['Parent_Category_Id'] = ''
        else: new_row['Parent_Category_Id'] = name_hash[row['categoryid']]

        if new_row['Parent_Category_Id'] == '': new_row['category_visible_root_name'] = new_row['categoryname']
        else: new_row['category_visible_root_name'] = new_row['categoryname'] = new_row['Parent_Category_Id']

        if categories_hash.get(new_row['categoryid']):
            new_row['category_product_count'] = len(categories_hash[new_row['categoryid']])
            new_row['category_product_sum'] = sum(categories_hash[new_row['categoryid']])
        else:
            new_row['category_product_count'] = 0
            new_row['category_product_sum'] = 0

        writer.writerow(new_row)

def main(): generate_csv([row for row in csv.DictReader(open(sys.argv[1]))], read_csv(sys.argv[2]), sys.argv[3])

if __name__ == '__main__': main()
