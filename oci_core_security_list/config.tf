# network labels may be used in security lists as aliases for CIDRs
# this map is forwarded to sl_lang module to do actual substitution
variable network_labels {
    default = {
        multiple = "10.0.0.0/16;6.0.0.0/16"
    }

    type = map(string)
}

# Named security lists
# - on this stage it's pure logical definition w/o connection to any VCN / Subnet
# - may be reused anytime to establish OCI resources
variable security_lists {
    default = {
        "super_user" = [   
                "permit tcp/1-65535 to all /* all ftp for all!!! */",
                "permit udp/1-65535 to 0.0.0.0/0 /* all udp for all!!! */",
            ],
        "regular_user" = [
                "permit tcp/1521-1523 to 0.0.0.0/0 /* db for all! */",
                "permit udp/53 to 0.0.0.0/0 /* DNS */",
            ],
        "vcn_traffic" = [   
                "permit tcp/1521-1523 to /sandbox/cmpx_network/vcn_test1 /* db for all! */",
                "permit udp/53 to /sandbox/cmpx_network/vcn_test1 /* DNS */",
                "accept icmp/3.4 from multiple /* PMTUD ingress */",
                "permit icmp/3.4 stateless to multiple /* PMTUD ingress */"
            ],
        "default" = [   
                "permit icmp/3.4 to 0.0.0.0/0 /* PMTUD egress */",
                "accept icmp/3.4 stateless from 0.0.0.0/0 /* PMTUD ingress */"
            ]
    }

    type = map(list(string))
}

# Security list assignment to OCI VCNs with all required data defined
# Notice the following:
# - SL location is encoded at the front the key, which is a URI
# - location should be a logical name, converted to compartment, however may be specified as compartment
# - compartment may be specified as an attribute to support object movement e.g. to decommission area
# - tags may be literally specified, may use tag_set name or may be omitted to use default tag_set name
# - OCI regular tag namespaces are ignored by lifecycle configuration
variable security_lists_assignment {
    default = {
        "/sandbox/cmpx_network/vcn_test1/super_user" = {
            compartment_fqn = "/sandbox"
            tag_set = "dev"
        },
        "/sandbox/cmpx_network/vcn_test1/regular_user" = {},
        "/sandbox/cmpx_network/vcn_test1/default" = {
            default = true
            defined_tags = { "Oracle-Standard.CostCenter" = "50"}
            freeform_tags = { "dept" = "dev2"}
        },
        "/sandbox/cmpx_network/vcn_test2/regular_user" = {
            compartment_fqn = "/sandbox"
            defined_tags = { "Oracle-Standard.CostCenter" = "51"}
            //freeform_tags = { "dept" = "dev"}
        },
        "/sandbox/cmpx_network/vcn_test2/default" = {
            default = true
            //compartment_fqn = "/sandbox"
        },
        "/sandbox/vcn_test3/regular_user" = {
            //compartment_fqn = "/sandbox/cmpx_network"
            defined_tags =  { "Oracle-Standard.CostCenter" = "49"}
            freeform_tags = { "dept" = "dev"}
        },
        "/sandbox/vcn_test3/default" = {
            default = true
            //compartment_fqn = "/sandbox"
            defined_tags =  { "Oracle-Standard.CostCenter" = "49"}
            freeform_tags = { "dept" = "dev"}
        },
        "/sandbox/vcn_test3/vcn_traffic" = {}
    }

  type = map(object({
    default         = optional(bool)

    defined_tags    = optional(map(string))
    freeform_tags   = optional(map(string))
    tag_set         = optional(string)

    compartment_fqn = optional(string)
  }))

}

# read VCN details for VCNs listed in local.ocids
data "oci_core_vcn" "ocids_vcns" {
    for_each = local.load_data.vcn ? {} : {for key, value in local.ocids : key => value if can(regex("^ocid1.vcn", value)) }

    vcn_id = each.value
}

# variable mapping to local
# Rule. Always map arguments to local constants to make it possible to preprocess vars if needed
locals {
    vcn_labels = local.load_data.vcn ? {for k,v in local.oci.vcn: k=> v.cidr_block} : {for k,v in data.oci_core_vcn.ocids_vcns : k=> join(";",v.cidr_blocks)}

    network_labels = merge( 
        local.vcn_labels,
        var.network_labels
    )
    security_lists = var.security_lists
    security_lists_assignment = var.security_lists_assignment
}

# resource creation control
#
variable create_sl {
    default = true

    type = bool
}

# to be used when objects are externally created
variable created_objects {
    default = null
}

locals {
    create_sl = var.create_sl
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
    created_objects = var.created_objects != null ? var.created_objects : merge(
      oci_core_security_list.sl_set,
      oci_core_default_security_list.sl_set
    )
    created_objects_name = "created_objects_security_list"
}