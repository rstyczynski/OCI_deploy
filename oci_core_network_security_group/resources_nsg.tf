
#
#  create resources
#

# output "nsg_deploy" {
#   value = local.nsg_deploy
# }
resource "oci_core_network_security_group" "nsg_set" {
    for_each = local.create_nsg ? local.nsg_deploy: {}

    vcn_id = each.value.vcn_id

    compartment_id = each.value.compartment_id 
            
    display_name = each.value.nsg_name

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    lifecycle {
        ignore_changes = [
            defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
        ]
    }
}

# output "nsg_rules_deploy_egress" {
#   value = local.nsg_rules_deploy_egress
# }
resource "oci_core_network_security_group_security_rule" "egress_nsg_set" {
    for_each =  local.create_nsg ? local.nsg_rules_deploy_egress : {}

    network_security_group_id = oci_core_network_security_group.nsg_set[each.value.nsg_fqn].id
    direction = "EGRESS"

    description = each.value.rule.description

    // replace _nsg.NSG_NAME into nsg_fqn prefixing NSG_NAME by vcn_fqn
    destination = can(regex("_nsg\\.", each.value.rule.destination)) ? oci_core_network_security_group.nsg_set[format("%s/%s",each.value.vcn_fqn,regex("_nsg\\.(.+)", each.value.rule.destination)[0])].id : each.value.rule.destination
    destination_type = can(regex("_nsg\\.", each.value.rule.destination)) ? "NETWORK_SECURITY_GROUP" : each.value.rule.destination_type
    
    protocol = each.value.rule.protocol
    stateless = each.value.rule.stateless

    dynamic "tcp_options" {
        for_each = each.value.rule.tcp_options != null ? [1] : []
        content {

            dynamic "destination_port_range"{
                for_each = each.value.rule.tcp_options.max != null ? [1] : []
                content {
                    min = each.value.rule.tcp_options.min
                    max = each.value.rule.tcp_options.max
                }
            }

            dynamic "source_port_range"{
                for_each = each.value.rule.tcp_options.source_port_range.max != null ? [1] : []
                content {
                    min = each.value.rule.tcp_options.source_port_range.min
                    max = each.value.rule.tcp_options.source_port_range.max
                }
            }
        }
    }

    dynamic "udp_options" {
        for_each = each.value.rule.udp_options != null ? [1] : []
        content {

            dynamic "destination_port_range"{
                for_each = each.value.rule.udp_options.max != null ? [1] : []
                content {
                    min = each.value.rule.udp_options.min
                    max = each.value.rule.udp_options.max
                }
            }

            dynamic "source_port_range"{
                for_each = each.value.rule.udp_options.source_port_range.max != null ? [1] : []
                content {
                    min = each.value.rule.udp_options.source_port_range.min
                    max = each.value.rule.udp_options.source_port_range.max
                }
            }
        }
    }

    dynamic "icmp_options" {
        for_each = each.value.rule.icmp_options != null ? [1] : []
        content {
            type = each.value.rule.icmp_options.type
            code = each.value.rule.icmp_options.code
        }
    } 
}


# output "nsg_rules_deploy_ingress" {
#   value = local.nsg_rules_deploy_ingress
# }
resource "oci_core_network_security_group_security_rule" "ingress_nsg_set" {
    for_each =  local.create_nsg ? local.nsg_rules_deploy_ingress: {}

    network_security_group_id = oci_core_network_security_group.nsg_set[each.value.nsg_fqn].id
    direction = "INGRESS"

    description = each.value.rule.description

    // replace _nsg.NSG_NAME into nsg_fqn prefixing NSG_NAME by vcn_fqn
    source = can(regex("_nsg\\.", each.value.rule.source)) ? oci_core_network_security_group.nsg_set[format("%s/%s",each.value.vcn_fqn,regex("_nsg\\.(.+)", each.value.rule.source)[0])].id : each.value.rule.source
    source_type = can(regex("_nsg\\.", each.value.rule.source)) ? "NETWORK_SECURITY_GROUP" : each.value.rule.source_type
    
    protocol = each.value.rule.protocol
    stateless = each.value.rule.stateless

    dynamic "tcp_options" {
        for_each = each.value.rule.tcp_options != null ? [1] : []
        content {

            dynamic "destination_port_range"{
                for_each = each.value.rule.tcp_options.max != null ? [1] : []
                content {
                    min = each.value.rule.tcp_options.min
                    max = each.value.rule.tcp_options.max
                }
            }

            dynamic "source_port_range"{
                for_each = each.value.rule.tcp_options.source_port_range.max != null ? [1] : []
                content {
                    min = each.value.rule.tcp_options.source_port_range.min
                    max = each.value.rule.tcp_options.source_port_range.max
                }
            }
        }
    }

    dynamic "udp_options" {
        for_each = each.value.rule.udp_options != null ? [1] : []
        content {

            dynamic "destination_port_range"{
                for_each = each.value.rule.udp_options.max != null ? [1] : []
                content {
                    min = each.value.rule.udp_options.min
                    max = each.value.rule.udp_options.max
                }
            }

            dynamic "source_port_range"{
                for_each = each.value.rule.udp_options.source_port_range.max != null ? [1] : []
                content {
                    min = each.value.rule.udp_options.source_port_range.min
                    max = each.value.rule.udp_options.source_port_range.max
                }
            }
        }
    }

    dynamic "icmp_options" {
        for_each = each.value.rule.icmp_options != null ? [1] : []
        content {
            type = each.value.rule.icmp_options.type
            code = each.value.rule.icmp_options.code
        }
    } 
}
