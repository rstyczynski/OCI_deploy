locals {
    vcn_deploy = local.vcn_deploy_step2

    vcn_deploy_step1 = { for vcn_fqn, data in module.vcn.vcn_deploy:
        vcn_fqn => {
            compartment_fqn = data.compartment_fqn
            compartment_id = data.compartment_id
            display_name = data.display_name
            cidr_block = data.cidr_block
            dns_label = data.dns_label
            description = data.description
            freeform_tags = data.freeform_tags
            defined_tags = data.defined_tags
        }
    }

    vcn_deploy_step2 = { for vcn_fqn, data in local.vcn_deploy_step1:
        vcn_fqn => {
            compartment_id = try(
                oci_identity_compartment.level1_compartments[data.compartment_fqn].id,
                oci_identity_compartment.level2_compartments[data.compartment_fqn].id,
                oci_identity_compartment.level3_compartments[data.compartment_fqn].id,
                oci_identity_compartment.level4_compartments[data.compartment_fqn].id,
                oci_identity_compartment.level5_compartments[data.compartment_fqn].id,
                oci_identity_compartment.level6_compartments[data.compartment_fqn].id,                
                "Error. Compartment not found!")
            display_name = data.display_name
            cidr_block = data.cidr_block
            dns_label = data.dns_label
            description = data.description
            freeform_tags = data.freeform_tags
            defined_tags = data.defined_tags
        }
    }
}

