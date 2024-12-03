# Copyright 2020-2024 Google, LLC.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SUCCESS = 0
ERROR = -1
BQ_ASSET = 'bigquery'
FILESET_ASSET = 'fileset'
SPAN_ASSET = 'spanner'
DATASET = 'BigQuery dataset'
BQ_TABLE = 'BigQuery table'
SPAN_TABLE = 'Spanner table'
FILESET = 'Fileset'
TAG_CREATED = 'TAG_CREATED'
TAG_UPDATED = 'TAG_UPDATED'
BQ_DATASET_TAG = 1
BQ_TABLE_TAG = 2
BQ_COLUMN_TAG = 3
BQ_RES = 'BQ'
GCS_RES = 'GCS'
SPAN_RES = 'SPAN' # future, not yet implemented
PUBSUB_RES = 'PUBSUB' # future, not yet implemented
STATIC_TAG = 1
DYNAMIC_TAG = 2