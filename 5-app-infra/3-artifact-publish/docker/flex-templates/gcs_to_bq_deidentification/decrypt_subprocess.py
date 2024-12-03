import sys
import base64
import tink
from tink import aead, cleartext_keyset_handle
from tink.integration import gcpkms
from google.cloud import secretmanager
import logging


def decrypt_payload(encrypted_payload_b64, kms_key_uri, wrapped_key):
    aead.register()

    # Configuration
    kms_key_uri = f"gcp-kms://{kms_key_uri}"

    # Initialize KMS client and decrypt the wrapped DEK
    gcp_client = gcpkms.GcpKmsClient(kms_key_uri, credentials_path=None)
    kms_client = gcp_client.get_aead(kms_key_uri)
    unwrapped_key_response = kms_client.decrypt(wrapped_key, b'')
    unwrapped_dek = unwrapped_key_response
    
    # Load the unwrapped DEK into Tink
    keyset_handle = cleartext_keyset_handle.read(tink.BinaryKeysetReader(unwrapped_dek))
    aead_primitive = keyset_handle.primitive(aead.Aead)
    
    # Decrypt the payload
    decrypted_payload = aead_primitive.decrypt(base64.b64decode(encrypted_payload_b64), b'')
    
    return decrypted_payload.decode('utf-8')

if __name__ == "__main__":
    
    # Get arguments for subprocess from decrypt_pubsub_to_bq
    encrypted_payload_b64 = sys.argv[1]
    kms_key_uri = sys.argv[2]
    wrapped_key = sys.argv[3]
    try:
        decrypted_data = decrypt_payload(encrypted_payload_b64, kms_key_uri, wrapped_key)
        sys.stdout.write(decrypted_data.strip())
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)
