
#
# TF provider
#

# Note. oracle/oci must be specified as hashicorp one will be selected by default

terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

