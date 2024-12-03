/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "dataflow_bucket" {
  description = "value of dataflow bucket"
  value       = try(module.data_ingestion.dataflow_bucket, null)
}

output "cloudfunction_bucket" {
  description = "value of cloudfunction bucket"
  value       = try(module.data_ingestion.cloudfunction_bucket, null)
}

output "pubsub_topic" {
  description = "The name of the Pub/Sub topic"
  value       = try(module.data_ingestion.pubsub_topic, null)
}

output "pubsub_topic_labels" {
  description = "Labels assigned to the Pub/Sub topic"
  value       = try(module.data_ingestion.pubsub_topic_labels, null)
}

output "pubsub_subscription_names" {
  description = "The name list of Pub/Sub subscriptions"
  value       = try(module.data_ingestion.pubsub_subscription_names, null)
}

output "pubsub_subscription_paths" {
  description = "The path list of Pub/Sub subscriptions"
  value       = try(module.data_ingestion.pubsub_subscription_paths, null)
}

output "pubsub_uri" {
  description = "The URI of the Pub/Sub topic"
  value       = try(module.data_ingestion.pubsub_uri, null)
}

output "pubsub_id" {
  description = "The ID of the Pub/Sub topic"
  value       = try(module.data_ingestion.pubsub_id, null)
}
