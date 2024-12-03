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

module "data_ingestion_topic" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 6.0"

  project_id             = var.project_id
  topic_labels           = var.topic_labels
  topic                  = var.topic
  topic_kms_key_name     = data.google_kms_crypto_key.key.id
  message_storage_policy = var.message_storage_policy

  create_topic = var.create_topic

  create_subscriptions        = var.create_subscriptions
  push_subscriptions          = var.push_subscriptions
  pull_subscriptions          = var.pull_subscriptions
  bigquery_subscriptions      = var.bigquery_subscriptions
  cloud_storage_subscriptions = var.cloud_storage_subscriptions
  subscription_labels         = var.subscription_labels

  topic_message_retention_duration = var.topic_message_retention_duration
  grant_token_creator              = var.grant_token_creator

  schema = var.schema


  depends_on = [data.google_kms_crypto_key.key]
}
