variable compartments {
    
    default = {
        # Notice that:
        # 1. Tenancy i.e. root compartment must be registered in ocids under "/"
        # 2. When top compartment is not managed by this module it must be specified in ocids map
        "/cmp_sandbox1" = {
            description = "let's play"
            defined_tags = { "Oracle-Standard.CostCenter" = "48"}
            freeform_tags = { "dept" = "dev"}
            enable_delete = true
        },
        "/cmp_sandbox1/cmpx_network" = {
            description = "network resources"
            defined_tags = { "Oracle-Standard.CostCenter" = "49"}
            freeform_tags = { "dept" = "dev"}
            enable_delete = true
        },
         "/cmp_sandbox1/cmpx_network/cmpx_governance" = {
            description = "governance objects"
            defined_tags = { "Oracle-Standard.CostCenter" = "50"}
            freeform_tags = { "dept" = "test"}
            enable_delete = true
        },
         "/cmp_sandbox1/cmpx_network/cmpx_governance/cmpx_decomission" = {
            description = "decomission area"
            defined_tags = { "Oracle-Standard.CostCenter" = "51"}
            freeform_tags = { "dept" = "test"}
            enable_delete = true
        },
        "/cmp_sandbox2" = {
            description = "let's play"
            defined_tags = { "Oracle-Standard.CostCenter" = "48"}
            freeform_tags = { "dept" = "dev"}
            enable_delete = true
        },
        "/cmp_sandbox2/cmp_network" = {
            description = "network resources"
            defined_tags = { "Oracle-Standard.CostCenter" = "49"}
            freeform_tags = { "dept" = "dev"}
            enable_delete = true
        },     
    }

  type = map(object({
    description    = string
    enable_delete  = optional(bool)
    defined_tags   = optional(map(string))
    freeform_tags  = optional(map(string))
  }))
}

// variable mapping to local
locals {
    compartments = var.compartments
}

#
# resource creation control
#
variable create_compartment {
    default = true

    type = bool
}

# to be used when objects are externally created
variable created_objects {
    default = null
}

locals {
    create_compartment = var.create_compartment
}


# 
# data interchange configuration
#
variable load_data {
    default = {cmp: false, vcn: false}
}

variable data_interface {
  default = "bucket"
}

locals {
    load_data = var.load_data
    data_interface = var.data_interface

    created_objects_name = "created_objects_compartments"
    created_objects = var.created_objects != null ? var.created_objects : merge(
      oci_identity_compartment.level1_compartments,
      oci_identity_compartment.level2_compartments,
      oci_identity_compartment.level3_compartments,
      oci_identity_compartment.level4_compartments,
      oci_identity_compartment.level5_compartments,
      oci_identity_compartment.level6_compartments
    )
}