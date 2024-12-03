#!/usr/bin/python
#
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import print_function
from google.cloud import bigquery
import base64
import json
import os

BIGQUERY_PROJECT = os.environ.get('PROJECT_ID_DATA')
REGION = os.environ.get('REGION')

DATA_TRANSFER_LOG_TABLE = f'{BIGQUERY_PROJECT}.dataflow_log_sink.dataflow_googleapis_com_worker'
LAST_30_DAYS = ('(select date(year, month, 01) from (select extract(year from current_date) as year,'
               ' extract(month from current_date) as month))')

bq_client = bigquery.Client(project=BIGQUERY_PROJECT)

def event_handler(request):
    request_json = request.get_json()
    #print('request_json:', request_json)

    mode = request_json['calls'][0][0].strip()
    project = request_json['calls'][0][1].strip()
    dataset = request_json['calls'][0][2].strip()
    table = request_json['calls'][0][3].strip()

    print(f"request parameters: mode={mode} project={project} dataset={dataset} table={table}")
    try:
        if mode == 'bytes':
            physical_bytes_sum = run(mode, project, dataset, table)
            print('physical_bytes_sum:', physical_bytes_sum)
            return json.dumps({"replies": [physical_bytes_sum]})

        elif mode == 'cost':
            egress_charges = run(mode, project, dataset, table)
            print('egress_charges:', egress_charges)
            return json.dumps({"replies": [egress_charges]})

        else:
            print('Error: invalid mode', mode)
            return json.dumps({"errorMessage": 'invalid mode'})


    except Exception as e:
        print("Exception caught: " + str(e))
        return json.dumps({"errorMessage": str(e)}), 400

def run(mode, project, dataset, table):

    print('Running in {} mode'.format(mode))

    physical_bytes_sum = 0

    # get the region for the dataset where the destination table resides
    location = bq_client.get_dataset(project + '.' + dataset).location
    print('location:', location)

    # are there any data transfer jobs that have written into this table
    jobs_exist_sql = (' SELECT resource.labels.region,'
                      ' SPLIT(SPLIT(jsonPayload.message, ",")[SAFE_ORDINAL(1)], ": ")[SAFE_ORDINAL(2)] AS project_dataset_table,'
                      ' SUM(CAST(TRIM(SPLIT(SPLIT(jsonPayload.message, ",")[SAFE_ORDINAL(2)], ": ")[SAFE_ORDINAL(2)]) AS INT64)) as total_bytes_inserted'
                      ' from `{}`'
                      ' where date(timestamp) >= {}'
                      ' and jsonPayload.message like "Table: %{}%" '
                      ' GROUP BY 1, 2'.format(DATA_TRANSFER_LOG_TABLE, LAST_30_DAYS, table))
    
    log_rows = list(bq_client.query(jobs_exist_sql).result())

    if len(log_rows) == 0:
        print('Table {} has no data inserted into'.format(table))
        return 0
    
    # data has been inserted into table
    for log_row in log_rows:
        src_region = list(log_row)[0]

        # inserts within same region -> no egress
        if src_region == location:
            print('Inserts within same region, no egress charges')
        else:
            # cross-region inserts, use input bytes of table to estimate egress
            phys_bytes_sql = ('select total_input_bytes from `{}`.`region-{}`.INFORMATION_SCHEMA.STREAMING_TIMELINE_BY_PROJECT '
                     'where dataset_id = "{}" and table_id = "{}" and date(start_timestamp) >= {}').format(project, src_region, dataset, table, LAST_30_DAYS)
    
            tbl_rows = list(bq_client.query(phys_bytes_sql).result())
            if len(tbl_rows) == 0:
                print('Error: missing physical bytes')
                return -1
            
            for tbl_row in tbl_rows:
                physical_bytes_sum += list(tbl_row)[0]

            print('{} bytes were transferred'.format(physical_bytes_sum))

    if mode == 'bytes':
        return physical_bytes_sum
    if mode == 'cost':
        return calculate_egress(location, src_region, physical_bytes_sum)
    else:
        print('Error: invalid mode')
        return -1


def calculate_egress(location, src_region, physical_bytes_sum):

    if location[0:2] == src_region[0:2]:
        # source and destination are both in same continent
        egress_usd = round((physical_bytes_sum / (1024 * 1024 * 1024)) * 0.01, 4)
    else:
        # source and destination are NOT in same continent
        egress_usd = round((physical_bytes_sum / (1024 * 1024 * 1024)) * 0.08, 4)
    return egress_usd