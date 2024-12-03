ingress_policies = [
  // users
  {
    "from" = {
      "identity_type" = "ANY_IDENTITY"
      "sources" = {
        "access_level" = "accessPolicies/ACCESS_CONTEXT_MANAGER_POLICY_ID/servicePerimeters/NONPROD_SERVICE_PERIMETER_NAME"
      }
    },
    "to" = {
      "resources" = [
        "projects/NONPROD_SHARED_RESTRICTED_PROJECT_NUMBER",    // prj-n-shared-restricted
        "projects/NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER",     // prj-n-bu4-domain-1-cnf
        "projects/NONPROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER", // prj-n-bu4-domain-1-ncnf
        "projects/NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER",   // prj-n-bu4-domain-1-ngst
      ]
      "operations" = {
        "compute.googleapis.com" = {
          "methods" = ["*"]
        }
        "dns.googleapis.com" = {
          "methods" = ["*"]
        }
        "logging.googleapis.com" = {
          "methods" = ["*"]
        }
        "storage.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudkms.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquery.googleapis.com" = {
          "methods" = ["*"]
        }
        "datacatalog.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
]

egress_policies = [
  // kms
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:sa-dataflow-controller@NONPROD_DATA_DOMAIN_INGEST_PROJECT_ID.iam.gserviceaccount.com",                     // prj-n-bu4-domain-1-ngst compute serviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com",            // prj-n-bu4-domain-1-ngst gserviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com",                  // prj-n-bu4-domain-1-ngst pubsub serviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER@compute-system.iam.gserviceaccount.com",                 // prj-n-bu4-domain-1-ngst compute serviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_INGEST_PROJECT_NUMBER@dataflow-service-producer-prod.iam.gserviceaccount.com", // prj-n-bu4-domain-1-ngst dataflow serviceaccount
        "serviceAccount:bq-NONPROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER@bigquery-encryption.iam.gserviceaccount.com",               // prj-n-bu4-domain-1-ncnf bq default account
        "serviceAccount:sa-dataflow-controller-reid@NONPROD_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com",                       // prj-n-bu4-domain-1-cnf dataflow controller sa
        "serviceAccount:bq-NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER@bigquery-encryption.iam.gserviceaccount.com",                   // prj-n-bu4-domain-1-cnf bq default account
        "serviceAccount:service-NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com",              // prj-n-bu4-domain-1-cnf gserviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER@compute-system.iam.gserviceaccount.com",                   // prj-n-bu4-domain-1-cnf compute serviceaccount
        "serviceAccount:service-NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER@dataflow-service-producer-prod.iam.gserviceaccount.com",   // prj-n-bu4-domain-1-cnf dataflow serviceaccount
      ]
    }
    "to" = {
      "resources" = [
        "projects/COMMON_KMS_PROJECT_NUMBER", // prj-c-kms
        "projects/NONPROD_KMS_PROJECT_NUMBER" //prj-n-kms 
      ]
      "operations" = {
        "compute.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudkms.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
  // Bigquery Data Catalog
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:DATA_DOMAIN_TF_NON_CONF_SA",                                                         // non-conf-terraform sa
        "serviceAccount:DATA_DOMAIN_TF_CONF_SA",                                                             // conf-terraform sa
        "serviceAccount:sa-dataflow-controller-reid@NONPROD_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com", // prj-n-bu4-domain-1-cnf dataflow controller sa
        "serviceAccount:cloud-run@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                       // prj-c-bu4-data-governance cloud run service agent
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@dlp-api.iam.gserviceaccount.com",             // prj-c-bu4-data-governance dlp service account
        "serviceAccount:tag-creator@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                     // prj-c-bu4-data-governance tag creator
        "serviceAccount:record-manager@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                  // prj-c-bu4-data-governance record manager
        "serviceAccount:report-engine@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                   // prj-c-bu4-data-governance report engine
        "group:CONF_DATA_VIEWER_EMAIL",                                                                      // cdmc-conf-data-viewer
        "group:NON_CONF_DATA_VIEWER_EMAIL",                                                                  // cdmc-data-viewer
        "group:ENCRYPTED_DATA_VIEWER_EMAIL",                                                                 // cdmc-encrypted-data-viewer
        "group:FINE_GRAINED_DATA_VIEWER_EMAIL",                                                              // cdmc-fine-grained-data-viewer
        "group:MASKED_DATA_VIEWER_EMAIL",                                                                    // cdmc-masked-data-viewer
      ]
    }
    "to" = {
      "resources" = [
        "projects/DATA_GOVERNANCE_PROJECT_NUMBER", // prj-c-bu4-data-governance
      ]
      "operations" = {
        "bigquery.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquerydatapolicy.googleapis.com" = {
          "methods" = ["*"]
        }
        "datacatalog.googleapis.com" = {
          "methods" = ["*"]
        }
        "storage.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
  // Artifacts Registry
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:DATA_DOMAIN_TF_INGESTION_SA",                                                          // injest-terraform sa
        "serviceAccount:DATA_DOMAIN_TF_CONF_SA",                                                               // conf-terraform sa
        "serviceAccount:sa-dataflow-controller@NONPROD_DATA_DOMAIN_INGEST_PROJECT_ID.iam.gserviceaccount.com", // prj-n-bu4-domain-1-ngst dataflow serviceaccount
        "serviceAccount:sa-dataflow-controller-reid@NONPROD_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com",   // prj-n-bu4-domain-1-cnf dataflow reid serviceaccount
      ]
    }
    "to" = {
      "resources" = [
        "projects/ARTIFACTS_PROJECT_NUMBER", // prj-c-bu4-artifacts
      ]
      "operations" = {
        "storage.googleapis.com" = {
          "methods" = ["*"]
        },
        "artifactregistry.googleapis.com" = {
          "methods" = ["*"]
        }

      }
    }
  },
  // Secrets
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:sa-dataflow-controller@NONPROD_DATA_DOMAIN_INGEST_PROJECT_ID.iam.gserviceaccount.com", // prj-n-bu4-domain-1-ngst compute serviceaccount
      ]
    }
    "to" = {
      "resources" = [
        "projects/COMMON_SECRETS_PROJECT_NUMBER", // prj-c-secrets
      ]
      "operations" = {
        "secretmanager.googleapis.com" = {
          "methods" = ["*"]
        },
      }
    }
  },
  // DLP
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:sa-dataflow-controller@NONPROD_DATA_DOMAIN_INGEST_PROJECT_ID.iam.gserviceaccount.com", // prj-n-bu4-domain-1-ngst compute serviceaccount
        "serviceAccount:sa-dataflow-controller-reid@NONPROD_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com",   // prj-n-bu4-domain-1-cnf dataflow controller sa
      ]
    }
    "to" = {
      "resources" = [
        "projects/DATA_GOVERNANCE_PROJECT_NUMBER", // prj-c-bu4-data-governance
      ]
      "operations" = {
        "dlp.googleapis.com" = {
          "methods" = ["*"]
        },
      }
    }
  },
  // Logging
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:DATA_DOMAIN_TF_CONF_SA",      // tf data doamain conf sa
        "serviceAccount:DATA_DOMAIN_TF_INGESTION_SA", // tf data doamain ingest sa
      ]
    }
    "to" = {
      "resources" = [
        "projects/COMMON_AUDIT_LOGS_PROJECT_NUMBER", // prj-c-logging
      ]
      "operations" = {
        "logging.googleapis.com" = {
          "methods" = ["*"]
        },
        "storage.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
  // Consumer project-1 data access
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "group:CONF_DATA_VIEWER_EMAIL",         // cdmc-conf-data-viewer
        "group:NON_CONF_DATA_VIEWER_EMAIL",     // cdmc-data-viewer
        "group:ENCRYPTED_DATA_VIEWER_EMAIL",    // cdmc-encrypted-data-viewer
        "group:FINE_GRAINED_DATA_VIEWER_EMAIL", // cdmc-fine-grained-data-viewer
        "group:MASKED_DATA_VIEWER_EMAIL",       // cdmc-masked-data-viewer
      ]
    }
    "to" = {
      "resources" = [
        "projects/NONPROD_CONSUMER_PROJECT_NUMBER", // prj-d-bu4-consumer-1
      ]
      "operations" = {
        "bigquery.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquerydatapolicy.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
]
