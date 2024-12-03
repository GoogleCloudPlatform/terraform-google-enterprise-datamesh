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

variable "project_id" {
  type        = string
  description = "The project ID to manage the Pub/Sub resources."
}

variable "region" {
  type        = string
  description = "The resource region"
  default     = "us-central1"

}

variable "keyring_name" {
  type        = string
  description = "Name of the keyring"
  default     = "sample-keyring"
}

variable "business_code" {
  type        = string
  description = "Business code"
}

variable "domain_name" {
  type        = string
  description = "value of Data domain name"
}

variable "environment" {
  type        = string
  description = "Environment"
}

variable "parameters" {
  type        = map(any)
  description = "Template specific Key/Value pairs to be forwarded to the pipeline's options; keys are case-sensitive based on the language on which the pipeline is coded, mostly Java. Note: do not configure Dataflow options here in parameters."
  default     = {}
}

variable "additional_parameters" {
  type        = map(any)
  description = "Additional parameters"
  default     = {}
}

variable "name" {
  type        = string
  description = "Name of the job"
  default     = "dataflow_flex_job"
}

variable "template_filename" {
  type        = string
  description = "The filename of the Dataflow job Flex Template."
}

variable "additional_experiments" {
  type        = list(string)
  description = "List of experiments that should be used by the job."
  default     = []
}

variable "autoscaling_algorithm" {
  type        = string
  description = "The algorithm to use for autoscaling."
  default     = null

  # validation {
  #   condition     = contains(["THROUGHPUT_BASED", "NONE"], var.autoscaling_algorithm)
  #   error_message = "Valid values for autoscaling_algorithm are: THROUGHPUT_BASED, NONE."
  # }
}

variable "enable_streaming_engine" {
  type        = bool
  description = "Immutable. Indicates if the job should use the streaming engine feature."
  default     = false

}

variable "ip_configuration" {
  type        = string
  description = "The configuration for VM IPs."
  default     = "WORKER_IP_PUBLIC"

  validation {
    condition     = contains(["WORKER_IP_PUBLIC", "WORKER_IP_PRIVATE"], var.ip_configuration)
    error_message = "Valid values for ip_configuration are: WORKER_IP_PUBLIC, WORKER_IP_PRIVATE."
  }
}

variable "labels" {
  type        = map(string)
  description = "The labels associated with this job."
  default     = {}
}

variable "launcher_machine_type" {
  type        = string
  description = "The machine type to use for the Dataflow job launcher."
  default     = null
}

variable "max_workers" {
  type        = number
  description = "Immutable. The maximum number of Google Compute Engine instances to be made available to your pipeline during execution, from 1 to 1000."
  default     = 1
}

variable "num_workers" {
  type        = number
  description = "Immutable. The initial number of Google Compute Engine instances for the job."
  default     = 1
}

variable "network" {
  type        = string
  description = "The network to which the job should be peered."
  default     = null
}

variable "sdk_container_image" {
  type        = string
  description = "The container image for the SDK."
  default     = null
}

variable "service_account_email" {
  type        = string
  description = "Service account email to run the workers as. This should be just an email"
}

variable "staging_location" {
  type        = string
  description = "The Cloud Storage path to use for staging files. Must be a valid Cloud Storage URL, beginning with gs://."
  default     = null
}

variable "subnetworks" {
  type        = list(string)
  description = "The subnetwork to which VMs will be assigned. Should be of the form \"regions/REGION/subnetworks/SUBNETWORK\""
  default     = null
}

variable "network_project_id" {
  type        = string
  description = "The project ID of the shared VPC's host (for shared vpc support)"
  default     = null
}

variable "temp_location" {
  type        = string
  description = "The Cloud Storage path to use for temporary files. Must be a valid Cloud Storage URL, beginning with gs://."
  default     = null
}

variable "transform_name_mapping" {
  type        = map(string)
  description = "Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job.Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job."
  default     = {}
}

variable "dataflow_gcs_bucket_url" {
  description = "The dataflow gcs template bucket url"
  type        = string
}

variable "kms_project_id" {
  type        = string
  description = "Project id of the kms project."
}
