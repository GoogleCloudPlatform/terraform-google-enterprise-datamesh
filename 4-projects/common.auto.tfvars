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

remote_state_bucket = "REMOTE_STATE_BUCKET"

consumer_groups = {
  confidential_data_viewer                  = "cdmc-conf-data-viewer@[YOUR-DOMAIN]"
  non_confidential_data_viewer              = "cdmc-data-viewer@[YOUR-DOMAIN]"
  non_confidential_encrypted_data_viewer    = "cdmc-encrypted-data-viewer@[YOUR-DOMAIN]"
  non_confidential_fine_grained_data_viewer = "cdmc-fine-grained-data-viewer@[YOUR-DOMAIN]"
  non_confidential_masked_data_viewer       = "cdmc-masked-data-viewer@d[YOUR-DOMAIN]"
}
