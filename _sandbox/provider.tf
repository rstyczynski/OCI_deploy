
#
# TF provider
#

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  region              = "me-dubai-1"
  auth                = "SecurityToken"
  config_file_profile = "oci_trial"
}
