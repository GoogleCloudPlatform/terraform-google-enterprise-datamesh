# Simple CSV encryptor: the script encrypts a raw csv file.

## Step 1: Create a virtual environment
```
python3 -m venv venv
```
## Step 2: Activate the virtual environment
```
source venv/bin/activate  # (macOS/Linux)

```
## Step 3: Install dependencies
```
pip install -r requirements.txt
```
## Step 4: Run the script
```bash
python simple-csv-raw-to-enc.py
```

Required flags

```bash
 --cryptoKeyName string
      Path to KMS Key as:
      projects/<project_id>/locations/<location>/keyRings/<keyrings>/cryptoKeys/<key>
  
--wrappedKey string
      Path to wrappedKey in Secret Manager as:
      projects/<project_id>/secrets/<secret>/versions/<version>

--input_file_path string
      Path to CSV file with raw data:
      path/to/file.csv

--output_file_path string
      Path to CSV file that will contain encrypted data:
      path/to/output.csv

```

## Requirements
- [python](https://www.python.org/downloads/release/python-3110/) 3.11