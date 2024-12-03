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

output "topic" {
  value       = try(module.data_ingestion_topic.topic, "")
  description = "The name of the Pub/Sub topic"
}

output "topic_labels" {
  value       = try(module.data_ingestion_topic.topic_labels, {})
  description = "Labels assigned to the Pub/Sub topic"
}

output "id" {
  value       = try(module.data_ingestion_topic.id, "")
  description = "The ID of the Pub/Sub topic"
}

output "uri" {
  value       = try(module.data_ingestion_topic.uri, "")
  description = "The URI of the Pub/Sub topic"
}

output "subscription_names" {
  value = try(module.data_ingestion_topic.subscription_names, [])

  description = "The name list of Pub/Sub subscriptions"
}

output "subscription_paths" {
  value = try(module.data_ingestion_topic.subscription_paths, [])

  description = "The path list of Pub/Sub subscriptions"
}
