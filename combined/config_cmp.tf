variable compartments {
    
    default = {
        "/cmp_team1" = {
            description = "let's play"
        },
        "/cmp_team1/cmp_network" = {
            description = "network resources"
        }     
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
