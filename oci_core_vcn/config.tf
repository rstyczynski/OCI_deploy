variable vcns {
    default = {
        "/sandbox/cmpx_network/vcn_test1" = {
          cidr_block  = "172.16.0.0/20"
          //dns_label   = "test1"

          defined_tags = { "Oracle-Standard.CostCenter" = "48"}
          freeform_tags = { "dept" = "dev"}
        },
        "/sandbox/cmpx_network/vcn_test2" = {
          cidr_block  = "172.17.0.0/20"
          //dns_label   = "test1"
          defined_tags = { "Oracle-Standard.CostCenter" = "48"}
          freeform_tags = { "dept" = "dev"}
        },
        "/sandboxXXX/vcn_test3a" = {
          cidr_block  = "172.18.0.0/20"
          //dns_label   = "test1"

          defined_tags = { "Oracle-Standard.CostCenter" = "48"}
          freeform_tags = { "dept" = "dev"}
        },
        "/sandbox/vcn_test3" = {
          cidr_block  = "172.18.0.0/20"
          //dns_label   = "test1"
          #compartment_fqn = "/sandboxXX"
          //"compartment_id" = "ocid1.compartment.oc1..aaaaaaaawemj6cyudmuistlyhoybisetjkwvbtqc2nel6c4ntpn4wzk43enq"
          //"compartment_id" = "ocid1.compartment.oc1..aaaaaaaa445rleuht66e7doov6xrq3336nwp2dzznmyw3q2vjnihcd4ssvmq"
          defined_tags = { "Oracle-Standard.CostCenter" = "48"}
          freeform_tags = { "dept" = "dev"}
        },
        "/spoke_GC2/vcn_test1" = {
          cidr_block  = "172.16.0.0/20"
          //dns_label   = "test1"

          defined_tags = { "Oracle-Standard.CostCenter" = "48"}
          freeform_tags = { "dept" = "dev"}
        },
         "/spoke_GC2/vcn_test2" = {
          cidr_block  = "172.16.0.0/20"
          dns_label   = "test2"

          defined_tags = { "Oracle-Standard.CostCenter" = "49"}
          freeform_tags = { "dept" = "test"}
        },
         "/hub_XY2/vcn_test3" = {
          cidr_block  = "172.16.0.0/20"
          //dns_label   = "test3"

          defined_tags = { "Oracle-Standard.CostCenter" = "51"}
          freeform_tags = { "dept" = "HR"}
        },
         "/hub_XY2/vcn_test4" = {
          cidr_block  = "172.16.0.0/20"
          //dns_label   = "test4"

          defined_tags = { "Oracle-Standard.CostCenter" = "53"}
          freeform_tags = { "dept" = "HR"}
        }         

    }

  type = map(object({
    cidr_block     = string
    dns_label      = optional(string)

    # TODO: Add tag_Set here2
    defined_tags   = optional(map(string))
    freeform_tags  = optional(map(string))

    compartment_fqn = optional(string)
    compartment_id = optional(string)     # TODO Remove cmp id from here
  }))
}


// variable mapping to local
locals {
    vcns = var.vcns
}

#
# resource creation control
#
variable create_vcn {
    default = true

    type = bool
}

# to be used when objects are externally created
variable created_objects {
    default = null
}

locals {
    create_vcn = var.create_vcn
}

#
# data interconnection
#
variable load_data {
    default = {cmp: true, vcn: false}
}

variable data_interface {
  default = "bucket"
}

locals {
    load_data = var.load_data
    data_interface = var.data_interface

    # save
    created_objects = var.created_objects != null ? var.created_objects : oci_core_vcn.vcns
    created_objects_name = "created_objects_vcns"
}
