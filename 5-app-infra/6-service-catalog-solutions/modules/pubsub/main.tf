/**
 * Copyright 2023 Google LLC
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

# resource "google_project_service_identity" "agent" {
#   provider = google-beta

#   project = data.google_project.project.project_id
#   service = "pubsub.googleapis.com"
# }

# resource "time_sleep" "wait_30_seconds" {
#   create_duration = "30s"

#   depends_on = [google_project_service_identity.agent]
# }

# resource "google_kms_crypto_key_iam_member" "kms-key-binding" {
#   crypto_key_id = data.google_kms_crypto_key.key.id
#   role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
#   member        = "serviceAccount:${google_project_service_identity.agent.email}"

#   depends_on = [time_sleep.wait_30_seconds]
# }

// sa-pubsub-writer@prj-d-bu2-domain-1-ngst-ay3k.iam.gserviceaccount.com
resource "google_pubsub_topic" "pubsub_topic" {
  provider = google-beta

  project                    = data.google_project.project.project_id
  name                       = var.topic_name
  message_retention_duration = var.message_retention_duration

  #Customer Managed Encryption Keys
  #Control ID: PS-CO-6.1
  #NIST 800-53: SC-12 SC-13
  #CRI Profile: PR.DS-1.1 PR.DS-1.2 PR.DS-2.1 PR.DS-2.2 PR.DS-5.1

  kms_key_name = data.google_kms_crypto_key.key.id

  #Configure Message Storage Policies
  #Control ID: PS-CO-4.1
  #NIST 800-53: AC-3 AC-17 AC-20
  #CRI Profile: PR.AC-3.1 PR.AC-3.2 PR.AC-4.1 PR.AC-4.2 PR.AC-4.3 PR.AC-6.1 PR.PT-3.1 PR.PT-4.1

  message_storage_policy {
    allowed_persistence_regions = var.locked_regions
  }
}
