variable ocids {
    default = {
      "/" = "ocid1.tenancy.oc1..aaaaaaaao33ryc7wv422dmz7pvsgtuiwkpashkrraafjknvqvu5avfc4wl3a"
      "/sandbox" = "ocid1.compartment.oc1..aaaaaaaawemj6cyudmuistlyhoybisetjkwvbtqc2nel6c4ntpn4wzk43enq"
      "/sandbox/cmpx_network" = "ocid1.compartment.oc1..aaaaaaaacqzbijemvmj4lzndc5654nooaavglkrwq7724ws2hxy4der6jwcq"
      "/sandbox/vcn_test3" = "ocid1.vcn.oc1.me-dubai-1.amaaaaaasyse3maa56uqcifmxxveeqqhvrzsmphwdyny2jfzvaf7cwg4drtq"
      "/sandbox/cmpx_network/vcn_test2" = "ocid1.vcn.oc1.me-dubai-1.amaaaaaasyse3maarlskwe52cge7nv4mq5kmxpmevzfoixvjlnpdb7sjckfq"
      "/sandbox/cmpx_network/vcn_test1" = "ocid1.vcn.oc1.me-dubai-1.amaaaaaasyse3maa4mavhqgrxzcypg2ohw3wduhignon7ialxb3aw2rbj7xa"
      "/hub1/drg_central" = "ocid1.drg.1"
      "/spoke1/lpg_spoke2" = "ocid1.lpg.1"
      "/spoke1/nat_internet" = "ocid1.nat.1"
      "/spoke1/igw_internet" = "ocid1.igw.1"
      "/spoke1/sg_osn" = "ocid1.sg.1"
      "/sandbox/vcn_test3/drg_default" = "ocid1.drg1"
      "/sandbox/cmpx_network/vcn_test1/drg_default" = "ocid1.drg2"
      "/sandbox/cmpx_network/vcn_test2/drg_default" = "ocid1.drg3"
      "sandbox/cmpx_network/vcn_test1/drg_default" = "ocid1.drg1a"
    }
    
    type = map(string)
}

variable locations {
    default = {
      "/hub_XY1"   = "/sandbox"
      "/spoke_GC1" = "/sandbox/cmpx_network"
      "/hub_XY2"   = "/cmp_sandbox2"
      "/spoke_GC2" = "/cmp_sandbox2/cmp_network"
      "/team1"     = "/cmp_team1/cmp_network"
      "/sandboxXXX" = "/sandbox"

    }
    
    type = map(string)
}

variable tag_sets {
    default = {
        none = {}
        dev = {
            defined_tags = { "Oracle-Standard.CostCenter" = "148"}
            freeform_tags = { "dept" = "development"}           
        },
        hr = {
            defined_tags = { "Oracle-Standard.CostCenter" = "49"}
            freeform_tags = { "dept" = "dev1"}            
        }
    }

    type = map(
        object({
            defined_tags    = optional(map(string))
            freeform_tags   = optional(map(string))
        })
    )
}

variable tag_set_default {
    default = "dev"

    type = string
}


locals {
    ocids = var.ocids
    locations = var.locations

    tag_sets = var.tag_sets
    tag_set_default = var.tag_set_default
}
