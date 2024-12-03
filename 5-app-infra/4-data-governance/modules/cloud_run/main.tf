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

locals {
  artifact_dir_structure = var.artifact_repository_folder != null ? "${var.artifact_repository_name}/${var.artifact_repository_folder}" : var.artifact_repository_name

  fqdn_image_name = "${var.image_region}-docker.pkg.dev/${var.artifact_project_id}/${local.artifact_dir_structure}/${var.image_name}:${var.image_tag}"
}

resource "google_cloud_run_v2_job" "cloud_run" {
  count    = var.cloud_run_type == "RUN" ? 1 : 0
  name     = replace(var.name, "_", "-")
  location = var.location
  project  = var.project_id
  template {
    template {
      containers {
        image = local.fqdn_image_name
        args  = var.args
        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }
        dynamic "env" {
          for_each = var.environment_variables != null ? var.environment_variables : {}

          content {
            name  = env.key
            value = env.value
          }
        }
      }
      timeout         = "${var.timeout_seconds}s"
      service_account = var.cloud_run_service_account
      encryption_key  = var.encryption_key
    }
  }
}

resource "google_cloud_run_v2_service" "cloud_run" {
  count    = var.cloud_run_type == "SERVICE" ? 1 : 0
  name     = replace(var.name, "_", "-")
  location = var.location
  project  = var.project_id

  template {
    containers {
      image = local.fqdn_image_name
      args  = var.args

      resources {
        cpu_idle = true
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }
      dynamic "env" {
        for_each = var.environment_variables != null ? var.environment_variables : {}

        content {
          name  = env.key
          value = env.value
        }
      }
    }
    timeout         = "${var.timeout_seconds}s"
    service_account = var.cloud_run_service_account
    encryption_key  = var.encryption_key

  }

  lifecycle {
    ignore_changes = [template[0].containers[0].env, template[0].containers[0].resources[0].cpu_idle, template[0].containers[0].resources[0].limits]
  }
}
