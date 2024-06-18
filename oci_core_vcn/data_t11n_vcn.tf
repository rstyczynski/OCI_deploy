#
# data preparation logic
#

# output vcn_deploy {
#     value = local.vcn_deploy
# }
locals {

    vcn_deploy = local.vcn_deploy_step3 

    // generate name and parent compartment (incl. id) 
    // from full path available in the key
    // this map is used as source of data for all logic
    vcn_deploy_step1 = { for vcn_fqn, data in local.vcns : 
        vcn_fqn => {
            display_name   = basename(vcn_fqn) // :)
            
            # Rule. Use location_fqn converted to compartment 
            location_fqn    = dirname(vcn_fqn) // :)
            compartment_fqn = try(data.compartment_fqn, null)
            compartment_id = try(data.compartment_id, null)

            # Rule. Optional attributes takes null value
            description = try(data.description, null)

            cidr_block  = data.cidr_block
            dns_label   = try(data.dns_label, null)

            defined_tags = data.defined_tags != null ? data.defined_tags : try(module.cfg.tag_sets[data.tags].defined_tags, module.cfg.tag_sets[module.cfg.tag_set_default].defined_tags, null)
            
            # Rule. Store fqn in resource's tag
            freeform_tags = merge(
                {fqn = vcn_fqn},
                data.freeform_tags != null ? data.freeform_tags : try(module.cfg.tag_sets[data.tags].freeform_tags, module.cfg.tag_sets[module.cfg.tag_set_default].freeform_tags, null)
            )
        }
    }

    vcn_deploy_step2 = {
        for vcn_fqn, data in local.vcn_deploy_step1 :
        vcn_fqn => {

            # apply compartment_fqn when provided 
            # else decode compartment_fqn from locations[data.location_fqn
            # else assign URI's location prefix to compartment_fqn
            location_fqn    = data.location_fqn
            compartment_fqn = data.compartment_fqn != null ? data.compartment_fqn : can(local.locations[data.location_fqn]) ? local.locations[data.location_fqn] : data.location_fqn
            compartment_id  = data.compartment_id

            display_name = data.display_name
            description  = data.description

            cidr_block  = data.cidr_block
            dns_label   = data.dns_label

            defined_tags   = data.defined_tags
            freeform_tags  = data.freeform_tags
        }
    }

    vcn_deploy_step3 = {
        for vcn_fqn, data in local.vcn_deploy_step2 :
        vcn_fqn => {

            # Rule. Resource location_fqn may be provided as compartment or logical location_fqn
            // compartment may be:
            // 1. provided as location_fqn name, resolved from ocids map
            // 2. provided as location_fqn name, resolved from created compartments map
            // 3. provided as compartment_fqn, resolved from ocids map
            // 4. provided as compartment_fqn, resolved from created compartments map
            // Note: compartment may be omitted or null, thus try is necessary here
            
            # compartment_id is used when provided
            # else take from ocids[data.compartment_fqn]
            # else take from module.comm.required_objects.cmp[data.compartment_fqn].id
            location_fqn = data.location_fqn
            compartment_fqn = data.compartment_fqn
            compartment_id = try(
                local.ocids[data.compartment_fqn],
                local.oci.cmp[data.compartment_fqn].id,
                "Error! Compartment id not decoded from location / compartment fqn."
            )

            display_name = data.display_name
            description  = data.description

            cidr_block  = data.cidr_block
            dns_label   = data.dns_label

            defined_tags   = data.defined_tags
            freeform_tags  = data.freeform_tags
        }
    }
}
