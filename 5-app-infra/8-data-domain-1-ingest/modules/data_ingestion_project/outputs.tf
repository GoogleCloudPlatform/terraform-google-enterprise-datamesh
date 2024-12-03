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

# output "data_ingestion_bucket" {
#   value       = module.data_ingestion_bucket.storage_bucket
#   description = "value of data ingestion bucket"
# }

output "dataflow_bucket" {
  description = "value of dataflow bucket"
  value       = module.dataflow_bucket.storage_bucket
}

output "cloudfunction_bucket" {
  description = "value of cloudfunction bucket"
  value       = module.cloudfunction_bucket.storage_bucket
}

output "pubsub_topic" {
  description = "The name of the Pub/Sub topic"
  value       = module.pub_sub_topic.topic
}

output "pubsub_topic_labels" {
  description = "Labels assigned to the Pub/Sub topic"
  value       = module.pub_sub_topic.topic_labels
}

output "pubsub_subscription_names" {
  description = "The name list of Pub/Sub subscriptions"
  value       = module.pub_sub_topic.subscription_names
}

output "pubsub_subscription_paths" {
  description = "The path list of Pub/Sub subscriptions"
  value       = module.pub_sub_topic.subscription_paths
}

output "pubsub_uri" {
  description = "The URI of the Pub/Sub topic"
  value       = module.pub_sub_topic.uri
}

output "pubsub_id" {
  description = "The ID of the Pub/Sub topic"
  value       = module.pub_sub_topic.id
}

# output "log_sink_writer_identity" {
#   description = "value of log sink writer identity"
#   value       = module.log_sink.writer_identity
# }
