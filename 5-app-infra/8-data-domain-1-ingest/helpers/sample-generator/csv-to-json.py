import csv
import json
import argparse
import os

# Configuration
csv_file = ''
json_file = ''  # Path to save the output JSON file


def convert_csv_to_json(in_file, output_file=None):
    if output_file is None:
        base_name = os.path.splitext(in_file)[0]  # Remove the .csv extension
        output_file = f"{base_name}.json"

    with open(in_file, mode='r', newline='') as csv_file:
        csv_reader = csv.DictReader(csv_file)

        # Open the JSON file to write each record as a separate JSON object
        with open(output_file, mode='w', newline='') as json_file:
            for row in csv_reader:
                json_object = json.dumps(row)
                json_file.write(json_object + '\n')

    print(f"CSV data successfully converted to {output_file}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--in_csv_file',
        required=True,
        help=(
            'Path to CSV file that needs to be converted to JSON'
        )
    )
    parser.add_argument(
        '--out_json_file',
        help=(
            'output JSON file name : Optional'
        )
    )

    args = parser.parse_args()

    convert_csv_to_json(args.in_csv_file, args.out_json_file)
