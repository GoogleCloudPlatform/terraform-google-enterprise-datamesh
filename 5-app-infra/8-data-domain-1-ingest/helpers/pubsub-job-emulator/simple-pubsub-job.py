
from __future__ import absolute_import
import time
import argparse
import json
import logging
from google.cloud import pubsub_v1, secretmanager
import tink
from tink import aead
from tink import cleartext_keyset_handle
from tink.integration import gcpkms
import base64


def publish_encrypted_messages(primitive, topic_path, input_file):
    with open(input_file, 'r') as file:
        for line in file:
            record = json.loads(line.strip())
            message_data = json.dumps(record)
            ciphertext = primitive.encrypt(message_data.encode('utf-8'), b'')
            encrypted_message = base64.b64encode(ciphertext)
            future = publisher.publish(topic_path, encrypted_message)
            future.result()  # Block until the message is published
            print(future.result())
            time.sleep(1)  # Sleep for a second before publishing another message


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '--cryptoKeyName',
        required=False,
        default="projects/prj-c-kms-fc4b/locations/us-central1/keyRings/sample-keyring/cryptoKeys/deidenfication_key_common",
        help=(
            'GCP KMS Key URI as'
            'projects/<PROJECT_ID>/locations/<LOCATION>/keyRings/<KEY_RING>/cryptoKeys/<KEY_NAME>'
        )
    )
    parser.add_argument(
        '--wrappedKey',
        required=False,
        default="projects/826586300218/secrets/kms-wrapper/versions/5",
        help=(
            'Keyset base64 encoded wrapped key from Secret Manager'
            'projects/<PROJECT_ID>/secrets/<SECRET_NAME>/versions/<VERSION>'
        )
    )
    parser.add_argument(
        '--topic_id',
        required=False,
        default="data_ingestion",
        help=(
            'Pub/Sub Topic to publish messages to'
            '<TOPIC_ID>'
        )
    )
    parser.add_argument(
        '--messages_file',
        required=False,
        default="/helpers/sample-generator/sample-100-raw.json",
        help=(
            'Sample json file containing messages in json format as:'
            '<PATH_TO_FILE>/<FILE_NAME>.json'
        )
    )
    parser.add_argument(
        '--project_id',
        required=False,
        default="prj-d-bu4-domain-1-ngst-ay3k",
        help=(
            'GCP Project ID where pubsub is running'
        )
    )

    args = parser.parse_args()

    # Initialize Pub/Sub publisher
    publisher = pubsub_v1.PublisherClient()

    # Set up variables from args
    input_file = args.messages_file  # Path to the input JSON file
    topic_path = publisher.topic_path(args.project_id, args.topic_id)
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
    publish_encrypted_messages(primitive=aead_primitive, input_file=input_file, topic_path=topic_path)
