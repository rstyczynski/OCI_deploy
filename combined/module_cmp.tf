module cmp {
    source = "../oci_identity_compartment"
    create_compartment = false
    
    data_interface = "bucket"

    compartments = local.compartments

    created_objects = merge(
      oci_identity_compartment.level1_compartments,
      oci_identity_compartment.level2_compartments,
      oci_identity_compartment.level3_compartments,
      oci_identity_compartment.level4_compartments,
      oci_identity_compartment.level5_compartments,
      oci_identity_compartment.level6_compartments
    )
}

#
# resource creation control
#
variable create_compartment {
    default = true

    type = bool
}

locals {
    create_compartment = var.create_compartment
}

#
# resource configuration data
#
output compartments_full {
    value = module.cmp.compartments_full
}

output level1_compartments {
    value = module.cmp.level1_compartments
}

output level2_compartments {
    value = module.cmp.level2_compartments
}

output level3_compartments {
    value = module.cmp.level3_compartments
}

output level4_compartments {
    value = module.cmp.level4_compartments
}

output level5_compartments {
    value = module.cmp.level5_compartments
}

output level6_compartments {
    value = module.cmp.level6_compartments
}


