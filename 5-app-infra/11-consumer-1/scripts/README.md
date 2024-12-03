# wrapped key from secrets in bytes

## Usage

To generate wrapped key in bytes format

```
python ./get_wrapped_key_bytes
```

Supported flags

```bash
 --wrapped_key string
        Name of the wrapped key from secrets in the format projects/<project_id>/secrets/<secret_name>/versions/<version>
```

## Requirements
- [python](https://www.python.org/downloads/release/python-3110/) 3.11
```
pip install google-cloud                
pip install google-cloud-secret-manager
```
