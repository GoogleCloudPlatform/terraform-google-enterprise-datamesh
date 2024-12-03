## **Data Access Management**

### **Introduction**

This repository provides a data access management application that facilitates the secure granting and control of access permissions to datasets.

### **Features**

* **User Permission Requests:** Users can request permission to data by providing a list of roles in the request body.
* **Permission Approval and Denial:** Administrators can approve or deny permission requests, granting or denying access based on the decision.
* **Request Listing:** Users can view a list of all permission requests.
* **Permission Details by ID:** Users can retrieve details of a specific permission request by its unique ID.

### **Consumers Group and Roles**
* **Data Viewers:** 
Users who can access non-confidential data.
    * **BigQuery Data Viewer** - roles/bigquery.dataViewer
    * **BigQuery Job User** - roles/bigquery.jobUser

* **Encrypted Data Viewers:** 
Users who can access non-confidential data with sensitive encrypted data.
    * **Cloud KMS CryptoKey Decrypter Via Delegation** - roles/cloudkms.cryptoKeyDecrypterViaDelegation

* **Fine-Grained Data Viewers:** 
Users who can access protected data by column-level access control.
    * **Fine-Grained Reader** - roles/datacatalog.categoryFineGrainedReader

* **Masked Data Viewers:** 
Users who can access non-confidential data with sensitive data masked.
    * **Masked Reader** - roles/bigquerydatapolicy.maskedReader

* **Confidential Data Viewers:** 
Users who can access confidential data.
    * **BigQuery Data Viewer** - roles/bigquery.dataViewer
    * **BigQuery Job User** - roles/bigquery.jobUser

### **API Endpoints**

#### **1. POST /v1/permission-requests/users**

* **Description:** Creates a permission request for a user to access a consumer group
* **Authentication:** Bearer token for the requesting user.
* **Request Body:**
    * `roles`: A list of strings representing the requested access roles (e.g., ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"]).
* **Response:**
    * **Success (201 Created):** JSON object containing the created request ID.
    * **Error:** Appropriate error code and message for invalid requests (e.g., unauthorized access, invalid dataset name).

#### **2. PUT /v1/permission-requests/{request_id}/approve**

* **Description:** Approves a pending permission request, granting access to the requested consumer group.
* **Authentication:** Bearer token for an authorized user (likely an admin).
* **Response:**
    * **Success (200 OK):** Empty response upon successful approval.
    * **Error:** Appropriate error code and message (e.g., unauthorized access, non-existent request ID).

#### **3. PUT /v1/permission-requests/{request_id}/deny**

* **Description:** Denies a pending permission request, rejecting access to the requested consumer group.
* **Authentication:** Bearer token for an authorized user (likely an admin).
* **Response:**
    * **Success (200 OK):** Empty response upon successful denial.
    * **Error:** Appropriate error code and message (e.g., unauthorized access, non-existent request ID).

#### **4. GET /v1/permission-requests/**

* **Description:** Retrieves a list of all permission requests.
* **Authentication:** Bearer token for an authorized user (likely an admin).
* **Response:**
    * **Success (200 OK):** JSON array containing details of requests, including request ID,  requested roles, and user information.
    * **Error:** Appropriate error code and message (e.g., unauthorized access).

#### **5. GET /v1/permission-requests/{request_id}**

* **Description:** Retrieves details of a specific permission request by its ID.
* **Authentication:** Bearer token for an authorized user.
* **Response:**
    * **Success (200 OK):** JSON object containing detailed information about the request, including request ID, status (pending, approved, denied), requested roles, user information, and timestamps.
    * **Error:** Appropriate error code and message (e.g., unauthorized access, non-existent request ID).
