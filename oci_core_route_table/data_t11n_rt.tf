
#
# route syntax interpreter to convert RT from human to digital format
#

# output module_rt_lang {
#     value = module.rt_lang
# }
module "rt_lang" {
    for_each = {for rt_fqn, rt_record in local.route_tables_assignment : rt_fqn => ""}

    source = "../../OCI_structures/RT_v01/"

    data_format = "rt_lang"    
    cidrs = local.network_labels
    ocids = module.cfg.ocids
    vcn_fqn = dirname(each.key)
    
    # select only routes for given route table
    rt_lang = {basename(each.key) = local.route_tables[basename(each.key)]}

    # module outputs are here:
    # rt_response
    # rt_errors
}

output module_rt_lang {
    value = module.rt_lang
}

#
# route tables
#
locals {

    rt_deploy = local.rt_deploy_step3
    rt_errors = local.rt_deploy_step1_gap

    rt_deploy_step1 = { for rt_fqn, data in local.route_tables_assignment : 
        rt_fqn => {
            display_name = basename(rt_fqn)

            location_fqn = dirname(dirname(rt_fqn))
            vcn_fqn = dirname(rt_fqn)

            compartment_fqn = try(data.compartment_fqn, null)

            defined_tags = data.defined_tags != null ? data.defined_tags : try(module.cfg.tag_sets[data.tag_set].defined_tags, module.cfg.tag_sets[module.cfg.tag_set_default].defined_tags, null)
            
            # Rule. Store fqn in resource's tag
            freeform_tags = merge(
                {fqn = rt_fqn},
                data.freeform_tags != null ? data.freeform_tags : try(module.cfg.tag_sets[data.tags].freeform_tags, module.cfg.tag_sets[module.cfg.tag_set_default].freeform_tags, null)
            )
        } if can(dirname(rt_fqn)) && startswith(rt_fqn, "/")
    } 

    # Rule. In case of dataset processing in chunks catch not processed records.
    rt_deploy_step1_gap = {
        # Rule. Mark variables holding unique identifier with _fqn suffix
        for rt_fqn, data in local.route_tables_assignment : 
        rt_fqn => {
            error = "Error! RT key does not recognised by expected patterns."
        } if ! (can(dirname(rt_fqn)) && startswith(rt_fqn, "/"))
    }

    rt_deploy_step2 = {
        for rt_fqn, data in local.rt_deploy_step1 :
        rt_fqn => {
            display_name = data.display_name

            # get rules in lex format. Not yet processed by lang module.
            # rules here are for debug purposes only
            rules = local.route_tables[data.display_name]

            # get route rules converted to objects to be used in resources
            route_rules = try(module.rt_lang[rt_fqn].rt_response[data.display_name], [])

            # Rule. Handle logical locations, converted to compartments
            location_fqn = data.location_fqn
            compartment_fqn = data.compartment_fqn != null ? data.compartment_fqn : can(local.locations[data.location_fqn]) ? local.locations[data.location_fqn] : data.location_fqn

            # Rule. Encode URI of associated object in URI
            vcn_fqn = data.vcn_fqn

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags
            
        }
    } 

    rt_deploy_step3 = {
        for rt_fqn, data in local.rt_deploy_step2 :
        rt_fqn => {
            display_name = data.display_name
            rules = data.rules
            route_rules = data.route_rules

            // Rule. Keep intermediate attributes for debug purposes.
            location_fqn = data.location_fqn
            compartment_fqn = data.compartment_fqn

            # compartment may be:
            # 1. resolved using ocids map from provided compartment_fqn
            # 2. loaded from created compartments map
            # Note: compartment may be omitted or null, thus try is necessary here
            compartment_id = try(
                local.ocids[data.compartment_fqn],
                local.oci.cmp[data.compartment_fqn].id,
                "Error! Compartment id not decoded compartment fqn."
            )
        
            vcn_fqn = data.vcn_fqn
            # vcn may be:
            # 1. provided as name resolved from ocids map
            # 2. loaded from created vcns map
            vcn_id = try( 
                local.ocids[data.vcn_fqn],
                local.oci.vcn[data.vcn_fqn].id,
                "Error! VCN id not decoded from vcn fqn."
            )

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags

        }
    }

}
