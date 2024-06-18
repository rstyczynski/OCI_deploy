#
# data preparation logic
#

locals {
    // generate name and parent compartment from full path available in the key
    // this map is used as source of data for all logic
    compartments_full = {
    for compartment_fqn , data in local.compartments : 
        compartment_fqn  => {
            name           = basename(compartment_fqn ) // :)
            description    = try(data.description, null)

            parent_compartment_fqn    = dirname(compartment_fqn ) // :)

            enable_delete  = try(data.enable_delete, null)

            defined_tags = data.defined_tags != null ? data.defined_tags : try(module.cfg.tag_sets[data.tags].defined_tags, module.cfg.tag_sets[module.cfg.tag_set_default].defined_tags, null)
            freeform_tags = data.freeform_tags != null ? data.freeform_tags : try(module.cfg.tag_sets[data.tags].freeform_tags, module.cfg.tag_sets[module.cfg.tag_set_default].freeform_tags, null)
        }
    }
    
  // level structures are mandatory to be able to get compartment_id of 
  // parent compartment

  level1_compartments = { for key, data in local.compartments_full : key =>
    {
        // no attributes, as only a key is important here
        // all the fields are taken from local.compartments_full
    } if length(split("/", key)) == 2 
  } 

  level2_compartments = { for key, data in local.compartments_full : key =>
    {
    } if length(split("/", key)) == 3 
  } 

  level3_compartments = { for key, data in local.compartments_full : key =>
    {
    } if length(split("/", key)) == 4 
  } 

  level4_compartments = { for key, data in local.compartments_full : key =>
    {
    } if length(split("/", key)) == 5 
  } 

  level5_compartments = { for key, data in local.compartments_full : key =>
    {
    } if length(split("/", key)) == 6 
  } 

    level6_compartments = { for key, data in local.compartments_full : key =>
    {
    } if length(split("/", key)) == 7 
  } 
}
