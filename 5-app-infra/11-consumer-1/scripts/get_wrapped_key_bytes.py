# Script to generate bytes format wrapped key from secrets

from google.cloud import secretmanager
import argparse
import base64

if __name__ == "__main__":
    # Set up argument parsing
    parser = argparse.ArgumentParser(
        description="Generate the bytes formatted wrapped key from secrets"
        )
    parser.add_argument(
        "--wrapped_key",
        required=True,
        help="Wrapped key from secrets as : projects/<project_id>/secrets/<secret_name>/versions/<version>")

    # Parse the arguments
    args = parser.parse_args()

    secret_client = secretmanager.SecretManagerServiceClient()
    response = secret_client.access_secret_version(name=args.wrapped_key)
    wrapped_key = response.payload.data.decode("UTF-8")
    wrapped_key_bytes = base64.b64decode(wrapped_key)

    print(wrapped_key_bytes)
