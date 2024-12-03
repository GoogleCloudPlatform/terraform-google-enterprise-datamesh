################################
#  Project Log Sink
################################

module "sink_destination" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 10.0"

  project_id               = module.nonconfidential_project.project_id
  dataset_name             = "dataflow_log_sink" // hardcoded due to functional dependencies
  log_sink_writer_identity = module.log_sink.writer_identity
  location                 = "us-central1"
}

module "log_sink" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 10.0"

  destination_uri        = module.sink_destination.destination_uri
  filter                 = "resource.type=\"dataflow_step\""
  parent_resource_id     = module.ingestion_project.project_id
  parent_resource_type   = "project"
  log_sink_name          = "dataflow-log-sink"
  unique_writer_identity = true
  bigquery_options = {
    use_partitioned_tables = true
  }
}
