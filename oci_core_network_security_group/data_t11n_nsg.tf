
#
# access policy language interpreter
#

module "sl_lang" {
    source = "../../OCI_structures/SL_v1/"

    sl_lang = local.network_security_groups

    // supply here list of CIDR labels

    // Note: NSG may target rule to another NSG in the same vcn.
    // To handle this I'm using sl_lang CIDR labels feature.
    // It works this way that any non CIDR string in CIDR's place
    // is replaced with value from local.cidrs map.
    // I'm supplying in this place label _nsg.${k}_$vcn_name, which is 
    // handled in NSG rule resources, which substitutes $vcn_name with proper
    // vcn to locate NSG OCID.
    cidrs = merge(
                local.network_labels,
                { for k, v in local.network_security_groups :
                    k => "_nsg.${k}"
                }
            )
}

#
# prepare data for deployment structures
#

locals {
    nsg_deploy = local.nsg_deploy_step3

    nsg_deploy_step1 = {
        for nsg_fqn, data in local.network_security_groups_assignment :
        nsg_fqn => {

            nsg_name = basename(nsg_fqn)
                                
            vcn_fqn = dirname(nsg_fqn)

            compartment_fqn = data.compartment_fqn

            defined_tags = data.defined_tags != null ? data.defined_tags : try(module.cfg.tag_sets[data.tag_set].defined_tags, module.cfg.tag_sets[module.cfg.tag_set_default].defined_tags, null)
            freeform_tags = merge(
                {fqn = nsg_fqn},
                data.freeform_tags != null ? data.freeform_tags : try(module.cfg.tag_sets[data.tags].freeform_tags, module.cfg.tag_sets[module.cfg.tag_set_default].freeform_tags, null)
            )
        }
    }

    nsg_deploy_step2 = {
        for nsg_fqn, data in local.nsg_deploy_step1 :
        nsg_fqn => {

            nsg_name = data.nsg_name
                                
            vcn_fqn = data.vcn_fqn

            compartment_fqn = try(data.compartment_fqn, dirname(data.vcn_fqn), "Error! Compartment not known.")

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags
        }
    }

    nsg_deploy_step3 = {
        for nsg_fqn, data in local.nsg_deploy_step2 :
        nsg_fqn => {

            nsg_name = data.nsg_name
            
            // vcn may be:
            // 1. provided as OCID
            // 2. stored in created vcns map
            vcn_id = try( 
                local.ocids[data.vcn_fqn],
                module.comm.required_objects.vcn[data.vcn_fqn].id,
                null
            )

            // compartment may be:
            // 1. provided as name resolved from ocids map
            // 2. loaded from created compartments map
            // 3. loaded from created vcns map
            // Note: compartment may be omitted or null, thus try is necessary here
            compartment_id = try(
                local.ocids[data.compartment_fqn],
                module.comm.required_objects.cmp[data.compartment_fqn].id,
                module.comm.required_objects.vcn[data.vcn_fqn].compartment_id,
                null
            )

            defined_tags = data.defined_tags
            freeform_tags = data.freeform_tags
        }
    }

    # 
    # egress
    # 

    nsg_rules_deploy_egress = {
        for idx, data in local.nsg_rules_deploy_egress_step2 :
            "${data.nsg_fqn}/${data.rule._position}" => data
    }

    // remove top levels maps 
    nsg_rules_deploy_egress_step2 = flatten([for vcn, data in local.nsg_rules_deploy_egress_step1 : [for k, v in data : v ]])
  
    nsg_rules_deploy_egress_step1= { 
        for nsg_fqn, data in local.network_security_groups_assignment :
        nsg_fqn => [
            for ndx, rule in module.sl_lang.sl_tf_egress[basename(nsg_fqn)].rules : {
                nsg_fqn = nsg_fqn
                rule = rule

                // to convert into NSG id in source and destination
                vcn_fqn = dirname(nsg_fqn)
            }
        ]
    }

    # 
    # ingress
    # 

    nsg_rules_deploy_ingress = {
        for idx, data in local.nsg_rules_deploy_ingress_step2 :
            "${data.nsg_fqn}/${data.rule._position}" => data
    }

    // remove top levels maps 
    nsg_rules_deploy_ingress_step2 = flatten([for vcn, data in local.nsg_rules_deploy_ingress_step1 : [for k, v in data : v ]])
  
    nsg_rules_deploy_ingress_step1= { 
        for nsg_fqn, data in local.network_security_groups_assignment :
        nsg_fqn => [
            for ndx, rule in module.sl_lang.sl_tf_ingress[basename(nsg_fqn)].rules : {
                nsg_fqn = nsg_fqn
                rule = rule

                // to convert into NSG id in source and destination
                vcn_fqn = dirname(nsg_fqn)
            }
        ]
    }
}

