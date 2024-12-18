/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_pubsub_topic_iam_member" "publisher" {
  project = local.injestion_project_id
  topic   = module.pub_sub_topic.topic
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.pubsub_writer_service_account}"
}

resource "google_storage_bucket_iam_member" "objectAdmin" {
  bucket = module.dataflow_bucket.storage_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.dataflow_controller_service_account}"
}
