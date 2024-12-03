import os

ALLOWED_ROLES = {
    "roles/bigquery.dataViewer",
    "roles/bigquery.jobUser",
    "roles/datacatalog.categoryFineGrainedReader",
    "roles/cloudkms.cryptoKeyDecrypterViaDelegation",
    "roles/bigquerydatapolicy.maskedReader",
}


# os.environ["CONFIDENTIAL_DATA_VIEWER_GROUP", None)


GROUPS_BY_ROLE = {
    "roles/bigquery.dataViewer": os.environ["NON_CONFIDENTIAL_DATA_VIEWER_GROUP"],
    "roles/bigquery.jobUser": os.environ["NON_CONFIDENTIAL_DATA_VIEWER_GROUP"],
    "roles/datacatalog.categoryFineGrainedReader": os.environ["NON_CONFIDENTIAL_FINE_GRAINED_DATA_VIEWER_GROUP"],
    "roles/cloudkms.cryptoKeyDecrypterViaDelegation": os.environ["NON_CONFIDENTIAL_ENCRYPTED_DATA_VIEWER_GROUP"],
    "roles/bigquerydatapolicy.maskedReader": os.environ["NON_CONFIDENTIAL_MASKED_DATA_VIEWER_GROUP"],
}
