#
# access policy language interpreter to convert SL/NSG from human to digital format
#

module "sl_lang" {
    source = "../../OCI_structures/SL_v1/"

    data_format = "sl_lang"    
    cidrs = local.network_labels
    sl_lang = local.security_lists

    # module outputs are here:
    # module.sl_lang.sl_tf_ingress[sl_name].rules
    # module.sl_lang.sl_tf_egress[sl_name].rules
}

# output network_labels {
#     value = module.sl_lang.cidrs
# }

# output sl_cidr {
#     value = module.sl_lang.sl_cidr
# }

# output sl_map {
#     value = module.sl_lang.sl_lang_map
# }

#
# prepare data for deployment structures
#
locals {
    
    # Rule. Prepare data for resources as precise as possible.

    #
    # prepare datasets for regular and default SL
    # 

    // oci_core_security_list dataset
    sl_deploy_regular = {for k, v in local.sl_deploy : 
        k => v if v.default == null || v.default == false}

    // oci_core_default_security_list dataset
    sl_deploy_default = {for k, v in local.sl_deploy : 
        k => v if v.default != null && v.default == true}

    #
    # prepare data
    #

    # Rule. Constants computation order is not important in HCL
    sl_deploy = local.sl_deploy_step3 

    sl_deploy_step1 = {
        # Rule. Mark variables holding unique identifier with _fqn suffix
        for sl_fqn, data in local.security_lists_assignment : 
        sl_fqn => {
            # Rule. Encode display_name in URI
            sl_name = basename(sl_fqn)

            location_fqn = dirname(dirname(sl_fqn))
            # compartment may be:
            # 0. Encoded in FQN (not preferred)
            # Rule. Add compartment fqn, id attributes to all FQN managed objects to be able to keep the resource in other place than encoded in URI
            # Rule. Rewrite attributes that will be computed in next step.
            compartment_fqn = try(data.compartment_fqn, null)
            
            # Rule. Encode URI of associated object in URI
            vcn_fqn = dirname(sl_fqn)

            # Rule. Generalize configurations that are reused e.g. sl, nsg, tags
            # Rule. Define default configurations to be used in state context.
            // Apply tags:
            // 1. provided in regular way
            // 2. provided as a set name
            // 3. default set name
            defined_tags = data.defined_tags != null ? data.defined_tags : try(module.cfg.tag_sets[data.tag_set].defined_tags, module.cfg.tag_sets[module.cfg.tag_set_default].defined_tags, null)
            freeform_tags = merge(
                {fqn = sl_fqn},
                data.freeform_tags != null ? data.freeform_tags : try(module.cfg.tag_sets[data.tags].freeform_tags, module.cfg.tag_sets[module.cfg.tag_set_default].freeform_tags, null)
            )
            default = data.default

        // TODO Rule. Use can(dirname(sl_fqn)) checks that data is encoded in a key. Use other data structure to provide data as attributes
        } if can(dirname(sl_fqn))
    } 

    # Rule. Data processing guarantees completeness of data set processing
    sl_deploy_step1_gap = {
        # Rule. Mark variables holding unique identifier with _fqn suffix
        for sl_fqn, data in local.security_lists_assignment : 
        sl_fqn => {
            sl_name = "Error! SL key does not recognised."
        } if ! can(dirname(sl_fqn))
    }

    sl_deploy_step2 = {
        for sl_fqn, data in merge(local.sl_deploy_step1, local.sl_deploy_step1_gap) :
        sl_fqn => {
            sl_name = data.sl_name

            # get rules in lex format. Not yet processed by lang module.
            # rules here are for debug purposes only
            rules = local.security_lists[data.sl_name]

            # get egress / ingress rules converted to objects to be used in resources
            egress_rules = module.sl_lang.sl_tf_egress[data.sl_name].rules
            ingress_rules = module.sl_lang.sl_tf_ingress[data.sl_name].rules

            location_fqn = data.location_fqn
            compartment_fqn = data.compartment_fqn != null ? data.compartment_fqn : can(local.locations[data.location_fqn]) ? local.locations[data.location_fqn] : data.location_fqn

            # Rule. Encode URI of associated object in URI
            vcn_fqn = data.vcn_fqn

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags
            
            default = data.default
        }
    } 

    sl_deploy_step3 = {
        for sl_fqn, data in local.sl_deploy_step2 :
        sl_fqn => {
            sl_name = data.sl_name
            rules = data.rules
            egress_rules = data.egress_rules
            ingress_rules = data.ingress_rules


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
                "Error! Compartment id not decoded from location / compartment fqn."
            )
        
            vcn_fqn = data.vcn_fqn
            # vcn may be:
            # 1. provided as name resolved from ocids map
            # 2. loaded from created vcns map
            vcn_id = try( 
                local.ocids[data.vcn_fqn],
                local.oci.vcn[data.vcn_fqn].id,
                "Error! VCN id not decoded from location / vcn fqn."
            )

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags

            default = data.default
        }
    }

}

#
# End.
#