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
#
# Note that all gateways' ocids must be registered in cfg.ocids
variable route_tables {
    default = {
        "route1" = [   
            "vcn route 10.1.0.1/32 via DRG ../drg_default",
            "vcn route 10.1.0.2/32 via DRG /hub1/drg_central ",
            # "route 10.1.0.3/32 via DRG /hub1/drg_central /* regular CIDR */",
            # "route /spoke_GC2/vcn_test2 via LPG /spoke1/lpg_spoke2 /* CIDR collected from VCN */",
            # "route internet via NAT /spoke1/nat_internet-access /* CIDR specified with label */",
            # "route _test.label_multiple via IGW /spoke1/igw_internet-access /* CIDR specified with test label */"
        ],
        "route2" = [ 
            "vcn route osn_object_storage via SGW /spoke1/sg_osn-storage /* route object storage */",
            "vcn route osn_all_osn_services via SGW /spoke1/sg_osn /* route all osn */",
            "vcn route osn_object_storage via DRG /hub1/drg_central  /* route object storage */",
            "vcn route osn_all_osn_services via DRG /hub1/drg_central  /* route all osn */"        ],
        # "route3" = [ 
            # "vcn route osn_object_storage via SGW /spoke1/sg_osn-storage /* route object storage */",
        #     "route osn_all_osn_services via SGW /spoke1/sg_osn /* route all osn */"
        # ]

    }

    type = map(list(string))
}

# Route Table assignment to OCI VCNs with all required data defined
# Notice the following:
# - RT location is encoded at the front the key, which is a URI
# - location should be a logical name, converted to compartment, however may be specified as compartment
# - compartment may be specified as an attribute to support object movement e.g. to decommission area
# - tags may be literally specified, may use tag_set name or may be omitted to use default tag_set name
# - OCI regular tag namespaces are ignored by lifecycle configuration
variable route_tables_assignment {
    default = {
        "/sandbox/cmpx_network/vcn_test1/route1" = {
            compartment_fqn = "/sandbox"
            tag_set = "dev"
        },
        "/sandbox/cmpx_network/vcn_test1/route2" = {
            default = true
            defined_tags = { "Oracle-Standard.CostCenter" = "50"}
            freeform_tags = { "dept" = "dev2"}
        },
        # "/sandbox/cmpx_network/vcn_test2/route1" = {
        #     compartment_fqn = "/sandbox"
        #     defined_tags = { "Oracle-Standard.CostCenter" = "51"}
        #     //freeform_tags = { "dept" = "dev"}
        # },
        # "/sandbox/cmpx_network/vcn_test2/route2" = {
        #     default = true
        #     //compartment_fqn = "/sandbox"
        # },
        # "/sandbox/vcn_test3/route2" = {
        #     //compartment_fqn = "/sandbox/cmpx_network"
        #     defined_tags =  { "Oracle-Standard.CostCenter" = "49"}
        #     freeform_tags = { "dept" = "dev"}
        # },
        # "/sandbox/vcn_test3/route1" = {
        #     default = true
        #     //compartment_fqn = "/sandbox"
        #     defined_tags =  { "Oracle-Standard.CostCenter" = "49"}
        #     freeform_tags = { "dept" = "dev"}
        # },
        # "/sandbox/vcn_test3/route3" = {}
    }

  type = map(object({
    default         = optional(bool)

    defined_tags    = optional(map(string))
    freeform_tags   = optional(map(string))
    tag_set         = optional(string)

    compartment_fqn = optional(string)
  }))

}

#
# Prepare OSN CIDR labels 
#
locals {
    region_key = data.oci_identity_region_subscriptions.region.region_subscriptions[0].region_key
    osn_labels = {
        osn_object_storage = format("OCI %s Object Storage", local.region_key),
        osn_all_osn_services = format("All %s Services in Oracle Services Network", local.region_key)
    }
}

data "oci_identity_region_subscriptions" "region" {
    tenancy_id = local.ocids["/"]
}


#
# Prepare VCN CIDR labels
#

# read VCN details for VCNs listed in local.ocids
data "oci_core_vcn" "ocids_vcns" {
    for_each = local.load_data.vcn ? {} : {for key, value in local.ocids : key => value if can(regex("^ocid1.vcn", value)) }

    vcn_id = each.value
}

# variable mapping to local
# Rule. Always map arguments to local constants to make it possible to preprocess vars if needed

output network_labels {
    value = local.network_labels
}
locals {
    vcn_labels = local.load_data.vcn ? {for k,v in local.oci.vcn: k=> v.cidr_block} : {for k,v in data.oci_core_vcn.ocids_vcns : k=> join(";",v.cidr_blocks)}

    network_labels = merge( 
        local.vcn_labels,
        var.network_labels,
        local.osn_labels
    )
    route_tables = var.route_tables
    route_tables_assignment = var.route_tables_assignment
}

#
# resource creation control
#
variable create_rt {
    default = true

    type = bool
}

# to be used when objects are externally created
variable created_objects {
    default = null
}

locals {
    create_rt = var.create_rt
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
    created_objects = oci_core_route_table.rt_vcn_set

    created_objects_name = "created_objects_route_table"
}