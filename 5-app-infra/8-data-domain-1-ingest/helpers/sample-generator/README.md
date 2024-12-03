# sample-cc-generator

## Usage

To generate csv data

```bash
go run main.go
```

Supported flags

```bash
 -count int
        Number of entries to generate. Defaults to 100 (default 100)
  -filename string
        Filename to write csv data. Defaults to data-${count}.csv
  -seed int
        Random seed for generator. Defaults to 1 (default 1)
```

To generate json data from csv

```bash
 python ./csv-to-json.py 
```
Supported flags
```bash
--in_csv_file
      Path to existing csv file
--out_json_file
      Path to where json file will be written to
```
## Requirements

- [Go](https://go.dev/doc/install) 1.16+
- [python](https://www.python.org/downloads/release/python-3110/) 3.11
