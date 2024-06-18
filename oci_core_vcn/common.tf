
#
# shared config
#
module cfg {
  source = "../cfg"
}
// variable mapping to local
locals {
    ocids = module.cfg.ocids
    locations = module.cfg.locations
}

#
# data interchange
#
module comm {

    source = "../comm"
    data_interface = local.data_interface
    # load
    load_data = local.load_data
    #save
    created_objects = local.created_objects
    created_objects_name = local.created_objects_name
}
locals {
  oci = module.comm.required_objects
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
