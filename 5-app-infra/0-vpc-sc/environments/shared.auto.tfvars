/**
 * Copyright 2021 Google LLC
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

// List of IPv4 address of target name servers for the forwarding zone configuration.
// See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones
target_name_server_addresses = [
  {
    ipv4_address    = "192.168.0.1",
    forwarding_path = "default"
  },
  {
    ipv4_address    = "192.168.0.2",
    forwarding_path = "default"
  }
]

ingress_policies = [
  // users
  {
    "from" = {
      "identity_type" = "ANY_IDENTITY"
      "sources" = {
        "access_level" = "accessPolicies/ACCESS_CONTEXT_MANAGER_POLICY_ID/servicePerimeters/COMMON_SERVICE_PERIMETER_NAME"
      }
    },
    "to" = {
      "resources" = [
        "projects/COMMON_SHARED_RESTRICTED_PROJECT_NUMBER", // prj-c-shared-restricted
        "projects/DATA_GOVERNANCE_PROJECT_NUMBER",          // prj-c-bu2-data-governance
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
        "cloudbuild.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudfunctions.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudkms.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudscheduler.googleapis.com" = {
          "methods" = ["*"]
        }
        "dlp.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquery.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquerydatapolicy.googleapis.com" = {
          "methods" = ["*"]
        }
        "bigquerydatatransfer.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudbuild.googleapis.com" = {
          "methods" = ["*"]
        }
        "run.googleapis.com" = {
          "methods" = ["*"]
        }
        "pubsub.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  }
]
egress_policies = [
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:bq-DATA_GOVERNANCE_PROJECT_NUMBER@bigquery-encryption.iam.gserviceaccount.com",      // prj-c-bu2-data-governance bq-encrypt-serviceaccount
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@dlp-api.iam.gserviceaccount.com",             // prj-c-bu2-data-governance dlp-api serviceaccount
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@gcp-sa-firestore.iam.gserviceaccount.com",    // prj-c-bu2-data-governance firestore service agent
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@gs-project-accounts.iam.gserviceaccount.com", // prj-c-bu2-data-governance spanner service agent
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com",       // prj-c-bu2-data-governance cloud run service agent
      ]
    }
    "to" = {
      "resources" = [
        "projects/COMMON_KMS_PROJECT_NUMBER",     // prj-c-kms
        "projects/COMMON_SECRETS_PROJECT_NUMBER", // prj-c-secrets
      ]
      "operations" = {
        "compute.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudkms.googleapis.com" = {
          "methods" = ["*"]
        }
        "secretmanager.googleapis.com" = {
          "methods" = ["*"]
        }
        "cloudbuild.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@serverless-robot-prod.iam.gserviceaccount.com", // prj-c-bu2-data-governance cloud run service agent
      ]
    }
    "to" = {
      "resources" = [
        "projects/ARTIFACTS_PROJECT_NUMBER", // prj-c-bu2-artifacts
      ]
      "operations" = {
        "artifactregistry.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
  {
    "from" = {
      "identity_type" = ""
      "identities" = [
        "serviceAccount:DATA_DOMAIN_TF_NON_CONF_SA",                                                              // non-conf-terraform sa
        "serviceAccount:DATA_DOMAIN_TF_CONF_SA",                                                                  // conf-terraform sa
        "serviceAccount:sa-dataflow-controller-reid@DEV_DATA_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com",     // prj-d-bu2-domain-1-cnf dataflow serviceaccount
        "serviceAccount:sa-dataflow-controller-reid@NONPROD_DATA_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com", // prj-n-bu2-domain-1-cnf dataflow controller sa
        "serviceAccount:sa-dataflow-controller-reid@PROD_DATA_DOMAIN_CONF_PROJECT_ID.iam.gserviceaccount.com",    // prj-p-bu2-domain-1-cnf dataflow controller sa
        "serviceAccount:cloud-run@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                            // prj-c-bu2-data-governance cloud run service agent
        "serviceAccount:service-DATA_GOVERNANCE_PROJECT_NUMBER@dlp-api.iam.gserviceaccount.com",                  // prj-c-bu2-data-governance dlp-api serviceaccount
        "serviceAccount:tag-creator@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                          // prj-c-bu2-data-governance tag creator
        "serviceAccount:record-manager@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                       // prj-c-bu2-data-governance record manager
        "serviceAccount:report-engine@DATA_GOVERNANCE_PROJECT_ID.iam.gserviceaccount.com",                        // prj-c-bu2-data-governance report engine
        "serviceAccount:project-service-account@DEV_DATA_DOMAIN_NON_CONF_PROJECT_ID.iam.gserviceaccount.com",     // prj-d-bu2-domain-1-ncnf project service account
      ]
    }
    "to" = {
      "resources" = [
        "projects/DEV_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER",     // prj-d-bu2-domain-1-ncnf
        "projects/DEV_DATA_DOMAIN_CONF_PROJECT_NUMBER",         // prj-d-bu2-domain-1-cnf
        "projects/NONPROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER", // prj-n-bu2-domain-1-ncnf
        "projects/NONPROD_DATA_DOMAIN_CONF_PROJECT_NUMBER",     // prj-n-bu2-domain-1-cnf-
        "projects/PROD_DATA_DOMAIN_NON_CONF_PROJECT_NUMBER",    // prj-p-bu2-domain-1-ncnf
        "projects/PROD_DATA_DOMAIN_CONF_PROJECT_NUMBER",        // prj-p-bu2-domain-1-cnf
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
  // Data Governence consumer masked data viewer access
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
        "projects/DEV_CONSUMER_PROJECT_NUMBER",     // prj-d-bu2-consumer-1
        "projects/NONPROD_CONSUMER_PROJECT_NUMBER", // prj-n-bu2-consumer-1
        "projects/PROD_CONSUMER_PROJECT_NUMBER",    // prj-p-bu2-consumer-1
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
