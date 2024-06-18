variable vcns {
    default = {
        "/cmp_team1/cmp_network/vcn_test1" = {
          cidr_block  = "172.16.0.0/20"
        },
         "/team1/vcn_test2" = {
          cidr_block  = "10.0.1.0/24"
        }     

    }

  type = map(object({
    cidr_block     = string
    dns_label      = optional(string)
    defined_tags   = optional(map(string))
    freeform_tags  = optional(map(string))
  }))
}


// variable mapping to local
locals {
    vcns = var.vcns
}