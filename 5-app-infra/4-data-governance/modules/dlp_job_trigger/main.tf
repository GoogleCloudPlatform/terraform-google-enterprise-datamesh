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
  parent = "projects/${var.project_id}/locations/${var.dlp_location}"

  job_triggers = flatten([
    for ds in var.dlp_job_inspect_datasets : [
      for table_id in ds.inspecting_table_ids : {
        inspection_dataset = ds.inspection_dataset
        resulting_dataset  = ds.resulting_dataset
        table_id           = table_id
        info_types         = ds.inspect_config_info_types
      }
    ]
  ])
}

resource "google_data_loss_prevention_job_trigger" "dlp_job_trigger" {
  for_each = { for job in local.job_triggers : "${job.inspection_dataset}_${job.table_id}" => job }

  parent       = local.parent
  description  = var.dlp_job_description
  display_name = each.value.table_id
  trigger_id   = var.dlp_job_trigger_id
  status       = var.dlp_job_status

  triggers {
    schedule {
      recurrence_period_duration = var.dlp_job_recurrence_period_duration
    }
  }

  inspect_job {
    storage_config {
      big_query_options {
        table_reference {
          project_id = var.data_project_id
          dataset_id = each.value.inspection_dataset
          table_id   = each.value.table_id
        }
        sample_method = ""
      }
    }

    inspect_config {

      dynamic "info_types" {
        for_each = toset(each.value.info_types)
        content {
          name = info_types.key
        }
      }
      min_likelihood = "LIKELY"
    }

    actions {
      save_findings {
        output_config {
          table {
            project_id = var.project_id
            dataset_id = each.value.resulting_dataset
            table_id   = each.value.table_id
          }
        }
      }
    }
  }
}
