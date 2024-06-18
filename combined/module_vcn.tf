module vcn {
    source = "../oci_core_vcn"
    create_vcn = false

    data_interface = "bucket"
    load_data = {cmp: false, vcn: false}

    # logical config
    vcns = local.vcns

    # save data
    created_objects = oci_core_vcn.vcns
}

#
# resource creation control (for next level module)
#
variable create_vcn {
    default = true

    type = bool
}

locals {
    create_vcn = var.create_vcn
}

#
# resource configuration data (for next level module)
#
output vcn_deploy {
    value = module.vcn.vcn_deploy
}

