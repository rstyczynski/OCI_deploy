
#
# shared config
#
module cfg {
  source = "../cfg"
}
// variable mapping to local
locals {
    ocids = module.cfg.ocids
}

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




