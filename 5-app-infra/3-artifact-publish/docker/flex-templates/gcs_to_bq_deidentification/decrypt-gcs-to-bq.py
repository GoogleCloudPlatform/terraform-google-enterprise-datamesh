# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, GoogleCloudOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery, BigQueryDisposition
from apache_beam.transforms import DoFn, ParDo, PTransform, BatchElements
import argparse
import subprocess
import json
import base64
import logging
import os
import ast

from apache_beam.internal import pickler
pickler.set_library(pickler.USE_CLOUDPICKLE)


# Decrypt file contents
class DecryptFile(beam.DoFn):
    def __init__(self, kms_key_uri: str, wrapped_key: str):
        super(DecryptFile, self).__init__()
        self.kms_key_uri = kms_key_uri

        # Parse JSON wrapped key
        from google.cloud import secretmanager
        secret_client = secretmanager.SecretManagerServiceClient()
        response = secret_client.access_secret_version(name=wrapped_key)
        wrapped_key = response.payload.data.decode("UTF-8")
        self.wrapped_key = json.loads(response.payload.data.decode("UTF-8"))['encryptedKeyset']

    def process(self, element):
        
        byte_data = ast.literal_eval(element)
        # Parse the records
        encrypted_payload = base64.b64decode(byte_data)

        try:
            # Run the decryption in a separate subprocess
            result = subprocess.run(
                ['python3', os.path.join(os.path.dirname(__file__), 'decrypt_subprocess.py'), 
                 base64.b64encode(encrypted_payload).decode('utf-8'),  
                 self.kms_key_uri, self.wrapped_key,
                 ],
                capture_output=True,
                text=True
            )

            if result.returncode == 0:
                # Yield the decrypted message
                yield result.stdout.strip()
            else:
                # Handle decryption failure
                print(f"Decryption failed: {result.stderr.strip()}")

        except Exception as e:
            print(f"Failed to process message: {e}")

class ConvertToJSON(beam.DoFn):
    def __init__(self, headers):
        self.headers = headers

    def process(self, element):
        values = element.split(',')
        json_record = dict(zip(self.headers, values))
        yield json.dumps(json_record)

# calculate total bytes written to BigQuery
class CalculateTotalBytes(beam.DoFn):
    def __init__(self, table_name):
        self.total_bytes = 0  # Initialize a variable to keep track of total bytes
        self.table = table_name

    def process(self, element):
        # Calculate the size of the JSON element in bytes
        element_size = len(json.dumps(element).encode('utf-8'))
        self.total_bytes += element_size  # Add the element's size to the total
        yield element

    def finish_bundle(self):
        # Log the total bytes written at the end of the bundle
        logging.info(f"Table: {self.table}, Total bytes written to BigQuery: {self.total_bytes}")

def normalize_data(data):
    """
    The template reads a json from PubSub that can be a single object
    or a List of objects. This function is used by a FlatMap transformation
    to normalize the input in to individual objects.
    See:
     - https://beam.apache.org/documentation/transforms/python/elementwise/flatmap/
    """  # noqa
    if isinstance(data, list):
        return data
    return [data]

def from_list_dicts_to_table(list_item):
    """
    Converts a Python list of dict object to a DLP API v2
    ContentItem with value Table.
    See:
     - https://cloud.google.com/dlp/docs/reference/rest/v2/ContentItem#Table
     - https://cloud.google.com/dlp/docs/inspecting-structured-text
    """
    headers = []
    rows = []
    for key in sorted(list_item[0]):
        headers.append({"name": key})
    for item in list_item:
        row = {"values": []}
        for item_key in sorted(item):
            row["values"].append({"string_value": item[item_key]})
        rows.append(row)
    table_item = {"table": {"headers": headers, "rows": rows}}
    return table_item

class MaskDetectedDetails(PTransform):

    def __init__(
            self,
            project=None,
            location="global",
            template_name=None,
            deidentification_config=None,
            timeout=None):

        self.config = {}
        self.project = project
        self.timeout = timeout
        self.location = location

        if template_name is not None:
            self.config['deidentify_template_name'] = template_name
        else:
            self.config['deidentify_config'] = deidentification_config

    def expand(self, pcoll):
        if self.project is None:
            self.project = pcoll.pipeline.options.view_as(
                GoogleCloudOptions).project
        if self.project is None:
            raise ValueError(
                'GCP project name needs to be specified '
                'in "project" pipeline option')
        return (
            pcoll
            | ParDo(_DeidentifyFn(
                self.config,
                self.timeout,
                self.project,
                self.location
            )))

def from_table_to_list_dict(content_item):
    """
    Converts a DLP API v2 ContentItem of type Table with a single row
    to a Python dict object.
    See:
     - https://cloud.google.com/dlp/docs/reference/rest/v2/ContentItem#Table
     - https://cloud.google.com/dlp/docs/inspecting-structured-text
    """
    result = []
    for row in content_item.table.rows:
        new_item = {}
        for index, val in enumerate(content_item.table.headers):
            new_item[val.name] = row.values[index].string_value
        result.append(new_item)
    return result

class _DeidentifyFn(DoFn):

    def __init__(
        self,
        config=None,
        timeout=None,
        project=None,
        location=None,
        client=None
    ):
        self.config = config
        self.timeout = timeout
        self.client = client
        self.project = project
        self.location = location
        self.params = {}

    def setup(self):
        from google.cloud import dlp_v2
        if self.client is None:
            self.client = dlp_v2.DlpServiceClient()
        self.params = {
            'timeout': self.timeout,
            'parent': "projects/{}/locations/{}".format(
                self.project,
                self.location
            )
        }
        self.params.update(self.config)

    def process(self, element, **kwargs):
        request = {
            'parent': self.params['parent'],
            'item': element
        }

        if self.config['deidentify_template_name'] is not None:
            request['deidentify_template_name'] = \
                self.config['deidentify_template_name']
        else:
            request['deidentify_config'] = self.config['deidentify_config']

        operation = self.client.deidentify_content(
            timeout=self.timeout,
            request=request
        )
        yield operation.item

def print_element_type(element):
    print(f"Element: {element}, Type: {type(element)}")
    return element

def run(argv=None):
    parser = argparse.ArgumentParser()
    
    parser.add_argument(
        '--gcs_input_file',
        required=True,
        help='Path to the input CSV file on GCS'
    )
    
    parser.add_argument(
        '--output_table',
        required=True,
        help='BigQuery output table in the format PROJECT:DATASET.TABLE'
    )
    
    parser.add_argument(
        '--bq_schema',
        required=True,
        help='Comma-separated list of BigQuery schema fields, e.g. name:STRING,age:INTEGER'
    )

    parser.add_argument(
        "--min_batch_size",
        default=10,
        type=int,
        help=(
            'Number of min records to be sent in a batch in '
            'the call to the Data Loss Prevention (DLP) API.'
        )
    )

    parser.add_argument(
        "--max_batch_size",
        default=1000,
        type=int,
        help=(
            'Number of max records to be sent in a batch in '
            'the call to the Data Loss Prevention (DLP) API.'
        )
    )

    parser.add_argument(
        '--dlp_project',
        required=True,
        help=(
            'ID of the project that holds the DLP template.'
        )
    )

    parser.add_argument(
        '--dlp_location',
        required=False,
        help=(
            'The Location of the DLP template resource.'
        )
    )
    parser.add_argument(
        '--deidentification_template_name',
        required=True,
        help=(
            'Name of the DLP Structured De-identification Template '
            'of the form "projects/<PROJECT>/locations/<LOCATION>'
            '/deidentifyTemplates/<TEMPLATE_ID>"'
        )
    )

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
    
    known_args, pipeline_args = parser.parse_known_args(argv)
    pipeline_options = PipelineOptions(
        pipeline_args,
        # runner='DirectRunner',  # Use DirectRunner for local testing
        # direct_num_workers=1  # Reduce parallelism to avoid threading issues
        # using cloudpickle over dill for serialization; observed issues in serializing on Dataflow
        pickle_library="cloudpickle",
    )

    with beam.Pipeline(options=pipeline_options) as p:
        # Extract schema headers from the schema argument
        headers = [field.split(':')[0] for field in known_args.bq_schema.split(',')]

        # Read CSV lines
        csv_lines = (
            p
            #Discard first line as is a header
            | 'Read CSV' >> beam.io.ReadFromText(known_args.gcs_input_file, skip_header_lines=1)    
        )

        # Convert to JSON for structured data
        decrypt_records = (
            csv_lines
            | 'Decrypt File Contents' >> beam.ParDo(DecryptFile(known_args.cryptoKeyName, known_args.wrappedKey))
            | 'Convert to JSON' >> beam.ParDo(ConvertToJSON(headers))
            | 'Parse JSON payload' >>
                beam.Map(json.loads)
            | 'Flatten lists' >>
                beam.FlatMap(normalize_data)
        )

        # Implement de-identification
        de_identified_messages = (
            decrypt_records
            | "Batching" >> BatchElements(
                min_batch_size=known_args.min_batch_size,
                max_batch_size=known_args.max_batch_size
                )
            | 'Convert dicts to table' >>
                beam.Map(from_list_dicts_to_table)
            | 'Call DLP de-identification' >>
            MaskDetectedDetails(
                project=known_args.dlp_project,
                location=known_args.dlp_location,
                template_name=known_args.deidentification_template_name
            )
            | 'Convert table to dicts' >>
                beam.FlatMap(from_table_to_list_dict)
            | 'Calculate Total Bytes' >> ParDo(CalculateTotalBytes(known_args.output_table))
            # stream insert into BQ table    
            | 'Write to BQ' >> beam.io.WriteToBigQuery(
                known_args.output_table,
                schema=known_args.bq_schema,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=BigQueryDisposition.WRITE_APPEND,
                method="STREAMING_INSERTS"
            )
        )
        

if __name__ == '__main__':
    run()
