# Simple PubSub job emulator that publishes data to PubSub topic. Reads raw data from json file, encrypts the data, and publishes to pubsub topic.

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
python simple-pubsub-job.py
```

Required flags

```bash
 --cryptoKeyName string
      Path to KMS Key as:
      projects/<project_id>/locations/<location>/keyRings/<keyrings>/cryptoKeys/<key>
  
--wrappedKey string
      Path to wrappedKey in Secret Manager as:
      projects/<project_id>/secrets/<secret>/versions/<version>

--topic_id string
      Path to PubSub topic id as:
      <topic_id>

--project_id string
      Project where the PubSub topic id exists:
      <project_id>

--messages_file string
      Path to JSON file with raw data:
      <path>/<file>.json

```

## Requirements
- [python](https://www.python.org/downloads/release/python-3110/) 3.11