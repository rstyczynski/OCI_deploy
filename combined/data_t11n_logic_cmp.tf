locals {
    compartments_full = {
    for compartment_fqn, data in module.cmp.compartments_full :
        compartment_fqn => {
            name           = data.name
            description    = data.description

            parent_compartment_fqn    = data.parent_compartment_fqn

            enable_delete  = data.enable_delete

            defined_tags   = data.defined_tags
            freeform_tags  = data.freeform_tags 
        }
    }

    level1_compartments = module.cmp.level1_compartments
    level2_compartments = module.cmp.level2_compartments
    level3_compartments = module.cmp.level3_compartments
    level4_compartments = module.cmp.level4_compartments
    level5_compartments = module.cmp.level5_compartments
    level6_compartments = module.cmp.level6_compartments
}