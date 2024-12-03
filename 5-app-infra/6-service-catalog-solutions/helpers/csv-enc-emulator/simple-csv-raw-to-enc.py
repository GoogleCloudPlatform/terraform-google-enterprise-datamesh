
from __future__ import absolute_import
import argparse
import logging
from google.cloud import secretmanager
import tink
from tink import aead
from tink import cleartext_keyset_handle
from tink.integration import gcpkms
import base64
import csv
import json

# Read raw data and Write encrypted data to new csv file


def write_encrypted_data(primitive, input_file, output_file):
    with open(input_file, mode='r') as in_file:
        with open(output_file, mode='w') as out_file:
            reader = csv.reader(in_file)
            for line in reader:
                row = ','.join(line)
                ciphertext = primitive.encrypt(row.encode('utf-8'), b'')
                encrypted_message = base64.b64encode(ciphertext)
                byte_as_string = repr(encrypted_message)
                out_file.write(f'{byte_as_string}\n')


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--cryptoKeyName',
        required=True,
        help=(
            'GCP KMS Key URI as'
            'projects/<PROJECT_ID>/locations/<LOCATION>/keyRings/<KEY_RING>/cryptoKeys/<KEY_NAME>'
        )
    )
    parser.add_argument(
        '--wrappedKey',
        required=True,
        help=(
            'Tink Keyset base64 encoded wrapped key from Secret Manager'
            'projects/<PROJECT_ID>/secrets/<SECRET_NAME>/versions/<VERSION>'
        )
    )
    parser.add_argument(
        '--input_file_path',
        required=True,
        help=(
            'Sample csv file containing raw data:'
            '<PATH_TO_FILE?/<FILE_NAME>.json'
        )
    )
    parser.add_argument(
        '--output_file_path',
        required=True,
        help=(
            'Sample csv file containing raw data:'
            '<PATH_TO_FILE?/<FILE_NAME>.json'
        )
    )

    args = parser.parse_args()

    # Set up variables from args
    input_file = args.input_file_path  # Path to the input CSV file
    output_file = args.output_file_path  # Path to the output CSV file, encrypted data

    # Initialize Tink
    aead.register()

    # Set up variables from args
    cryptoKeyName = f'gcp-kms://{args.cryptoKeyName}'
    wrappedKey = args.wrappedKey

    # Initialize the GCP KMS client
    gcp_client = gcpkms.GcpKmsClient(key_uri=cryptoKeyName, credentials_path=None)
    kms_aead = gcp_client.get_aead(cryptoKeyName)

    # Initialize the Secret Manager client
    secret_client = secretmanager.SecretManagerServiceClient()

    # Access the secret version
    response = secret_client.access_secret_version(name=wrappedKey)
    wrapped_keyset = response.payload.data.decode("UTF-8")
    wrapped_key = json.loads(response.payload.data)['encryptedKeyset'].encode('utf-8')

    # Extract the encrypted keyset and decrypt it
    encrypted_keyset = base64.b64decode(wrapped_key)
    decrypted_keyset = kms_aead.decrypt(encrypted_keyset, b'')

    # Load the decrypted keyset into a Tink keyset handle
    decrypted_keyset_handle = cleartext_keyset_handle.read(tink.BinaryKeysetReader(decrypted_keyset))

    # Get the AEAD primitive
    aead_primitive = decrypted_keyset_handle.primitive(aead.Aead)

    # Publish sample messages to Pub/Sub topic
    write_encrypted_data(primitive=aead_primitive, input_file=input_file, output_file=output_file)
