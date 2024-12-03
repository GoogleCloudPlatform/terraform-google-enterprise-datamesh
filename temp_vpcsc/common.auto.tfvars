egress_policies = [
  // kms
  {
    "from" = {
      "identity_type" = "ANY_IDENTITY"
    }
    "to" = {
      "resources" = [
        "projects/COMMON_KMS_PROJECT_NUMBER",  // prj-c-kms
        "projects/NONPROD_KMS_PROJECT_NUMBER", //prj-n-kms
        "projects/PROD_KMS_PROJECT_NUMBER",    // prj-p-kms
        "projects/DEV_KMS_PROJECT_NUMBER",     // prj-d-kms
      ]
      "operations" = {
        "cloudkms.googleapis.com" = {
          "methods" = ["*"]
        }
      }
    }
  },
]
