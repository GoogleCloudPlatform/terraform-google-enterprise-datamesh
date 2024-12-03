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

variable "job_name" {
  type        = string
  description = "Name of the flex job."
  validation {
    condition     = can(regex("^[-0-9A-Za-z]+$", var.job_name))
    error_message = "Only alphanumeric and hyphens are allowed [-0-9A-Za-z]."
  }
}

variable "data_domain" {
  description = "Data Domain name."
  type        = string
  default     = "domain-1"
}

variable "project_id" {
  type        = string
  description = "Optional Project ID."
  default     = null
}

variable "region" {
  type        = string
  description = "The resource region, one of [us-central1, us-east4]."
  default     = "us-central1"
  validation {
    condition     = contains(["us-central1", "us-east4"], var.region)
    error_message = "Region must be one of [us-central1, us-east4]."
  }
}

#Labeling Tag
#Control ID: GCS-CO-6.4
#NIST 800-53: SC-12
#CRI Profile: PR.IP-2.1 PR.IP-2.2 PR.IP-2.3

variable "labels" {
  description = "Labels to be attached to the buckets"
  type        = map(string)
  default = {
    #Labelling tag
    #Control ID: GCS-CO-6.4
    #NIST 800-53: SC-12
    #CRI Profile: PR.IP-2.1 PR.IP-2.2 PR.IP-2.3

    label = "samplelabel"

    #Owner Tag
    #Control ID: GCS-CO-6.8
    #NIST 800-53: SC-12
    #CRI Profile: PR.IP-2.1 PR.IP-2.2 PR.IP-2.3

    owner = "testowner"

    #Classification Tag
    #Control ID: GCS-CO-6.18
    #NIST 800-53: SC-12
    #CRI Profile: PR.IP-2.1 PR.IP-2.2 PR.IP-2.3

    classification = "dataclassification"
  }
}

variable "keyring_name" {
  description = "Central keyring name"
  type        = string
  default     = "sample-keyring"
}

variable "dataflow_template_jobs" {
  type = object({
    image_name            = string
    template_filename     = string
    additional_parameters = optional(map(string))
  })
  description = "Dataflow template job"
  default = {
    image_name            = "us-central1-docker.pkg.dev/prj-c-bu2-artifacts-ks3d/flex-templates/samples/gcs_to_bq_deidentification:latest"
    template_filename     = "gs://bkt-prj-c-bu2-artifacts-ks3d-us-central1-tpl-b58f/flex-template-samples/gcs_to_bq_deidentification.json"
    additional_parameters = {}
  }
}

variable "autoscaling_algorithm" {
  type        = string
  description = "The algorithm to use for autoscaling."
  default     = null
}

variable "enable_streaming_engine" {
  type        = bool
  description = "Immutable. Indicates if the job should use the streaming engine feature."
  default     = false
}

variable "ip_configuration" {
  type        = string
  description = "The configuration for VM IPs."
  default     = "WORKER_IP_PRIVATE"

  validation {
    condition     = contains(["WORKER_IP_PUBLIC", "WORKER_IP_PRIVATE"], var.ip_configuration)
    error_message = "Valid values for ip_configuration are: WORKER_IP_PUBLIC, WORKER_IP_PRIVATE."
  }
}

variable "additional_experiments" {
  type        = list(string)
  description = "List of experiments that should be used by the job."
  default     = []
}

variable "launcher_machine_type" {
  type        = string
  description = "The machine type to use for the Dataflow job launcher."
  default     = "n1-standard-1"
}

variable "max_workers" {
  type        = number
  description = "Immutable. The maximum number of Google Compute Engine instances to be made available to your pipeline during execution, from 1 to 1000."
  default     = 10
}

variable "num_workers" {
  type        = number
  description = "Immutable. The initial number of Google Compute Engine instances for the job."
  default     = 1
}

variable "sdk_container_image" {
  type        = string
  description = "The container image for the SDK."
  default     = null
}

variable "staging_location" {
  type        = string
  description = "The Cloud Storage path to use for staging files. Must be a valid Cloud Storage URL, beginning with gs://."
  default     = null
}

variable "temp_location" {
  type        = string
  description = "The Cloud Storage path to use for temporary files. Must be a valid Cloud Storage URL, beginning with gs://."
  default     = null
}

variable "parameters" {
  type        = map(any)
  description = "Template specific Key/Value pairs to be forwarded to the pipeline's options; keys are case-sensitive based on the language on which the pipeline is coded, mostly Java. Note: do not configure Dataflow options here in parameters."
  default     = {}
}

variable "addtional_parameters" {
  type        = map(any)
  description = "Additional parameters"
  default     = {}
}

variable "transform_name_mapping" {
  type        = map(string)
  description = "Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job.Only applicable when updating a pipeline. Map of transform name prefixes of the job to be replaced with the corresponding name prefixes of the new job."
  default     = {}
}

variable "restricted_host_project_id" {
  description = "Shared network project id."
  type        = string
  default     = "RESTRICTED_HOST_PROJECT_ID"
}
