# network labels may be used in security lists as aliases for CIDRs
# this map is forwarded to sl_lang module to do actual substitution
variable network_labels {
    default = {
        all = "0.0.0.0/0;1.0.0.0/16"
    }

    type = map(string)
}

# Named network security group
# - on this stage it's pure logical definition w/o connection to any VCN / VNIC
# - may be reused anytime to establish OCI resources
variable network_security_groups {
    default = {
        "nsg_super_user" = [   
                "permit tcp/1-65535 to all /* all ftp or all! */",
                "permit udp/1-65535 to 0.0.0.0/0 /* all udp for all */",
            ],
        "nsg_regular_user" = [   
                "permit tcp/1521-1523 to nsg_super_user /* db for all! */",
                "permit udp/53 to 0.0.0.0/0 /* DNS */",
                "accept tcp/80 from all /* welcome! */"
            ],
        "nsg_app1" = [   
                "permit tcp/1521-1523 to nsg_regular_user /* db for users! */",
                "permit icmp/3,4 to /sandbox/cmpx_network/vcn_test1 /* icmp */",
                "accept tcp/443 from nsg_app2 /* welcome ssl! */"
            ],
        "nsg_app2" = [   
                "permit tcp/80-90 to 0.0.0.0/0 /* db for users! */",
                "accept tcp/443 from nsg_app1 /* welcome ssl! */",
                "permit icmp/3,4 to nsg_app1 /* icmp */"
            ]
    }

    type = map(list(string))
}


variable network_security_groups_assignment {
    default = {
        "/sandbox/cmpx_network/vcn_test1/nsg_super_user" = {},
        "/sandbox/cmpx_network/vcn_test2/nsg_regular_user" = {},
        "/sandbox/cmpx_network/vcn_test2/nsg_super_user" = {},
        "/sandbox/vcn_test3/nsg_regular_user" = {},
        "/sandbox/vcn_test3/nsg_super_user" = {},
        "/sandbox/vcn_test3/nsg_app1" = {},
        "/sandbox/vcn_test3/nsg_app2" = {}
    }

    type = map(
        object({
            compartment_fqn = optional(string)
            
            defined_tags    = optional(map(string))
            freeform_tags   = optional(map(string))
            tag_set         = optional(string)
        })
    )
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
    network_security_groups = var.network_security_groups
    network_security_groups_assignment = var.network_security_groups_assignment
}

#
# resource creation control
#
variable create_nsg {
    default = true

    type = bool
}
# to be used when objects are externally created
variable created_objects {
    default = null
}

locals {
    create_nsg = var.create_nsg
}

#
# data interconnection
#
variable load_data {
    default = {cmp: true, vcn: true}
}

variable data_interface {
  default = "bucket"
}


locals {
    load_data = var.load_data
    data_interface = var.data_interface

    # save
    created_objects_name = "created_objects_network_security_group"
    created_objects = var.created_objects != null ? var.created_objects : { 
        networksecuritygroups = oci_core_network_security_group.nsg_set
        networksecuritygroup_rules = merge(
            oci_core_network_security_group_security_rule.egress_nsg_set,
            oci_core_network_security_group_security_rule.ingress_nsg_set
        )
    }
}