
#
#  create resources
#

# Rule. Keep output ready to debug resource creation
# output sl_deploy {
#     value = local.sl_deploy
# }
resource "oci_core_security_list" "sl_set" {
    for_each = local.create_sl ? local.sl_deploy_regular : {}

    # Rule. Prepare all attributes for resource out of resource block
    vcn_id = each.value.vcn_id

    compartment_id = each.value.compartment_id 
        
    display_name = each.value.sl_name

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    dynamic "egress_security_rules" {
        for_each =  each.value.egress_rules # module.sl_lang.sl_tf_egress[each.value.sl_name].rules
        content {
            description = egress_security_rules.value.description
            destination = egress_security_rules.value.destination
            destination_type = egress_security_rules.value.destination_type
            protocol = egress_security_rules.value.protocol
            
            dynamic "tcp_options" {
                for_each = egress_security_rules.value.tcp_options != null ? [1] : []
                content {
                    min = egress_security_rules.value.tcp_options.min
                    max = egress_security_rules.value.tcp_options.max
                    
                    dynamic "source_port_range"{
                        for_each = egress_security_rules.value.tcp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = egress_security_rules.value.tcp_options.source_port_range.min
                            max = egress_security_rules.value.tcp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "udp_options" {
                for_each = egress_security_rules.value.udp_options != null ? [1] : []
                content {
                    min = egress_security_rules.value.udp_options.min
                    max = egress_security_rules.value.udp_options.max
                    dynamic "source_port_range"{
                        for_each = egress_security_rules.value.udp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = egress_security_rules.value.udp_options.source_port_range.min
                            max = egress_security_rules.value.udp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "icmp_options" {
                for_each = egress_security_rules.value.icmp_options != null ? [1] : []
                content {
                    type = egress_security_rules.value.icmp_options.type
                    code = egress_security_rules.value.icmp_options.code
                }
            } 

        }
    } 
    
    dynamic "ingress_security_rules" {
        for_each = each.value.ingress_rules #module.sl_lang.sl_tf_ingress[each.value.sl_name].rules
        content {
            description = ingress_security_rules.value.description
            source = ingress_security_rules.value.source
            source_type = ingress_security_rules.value.source_type
            protocol = ingress_security_rules.value.protocol
            
            dynamic "tcp_options" {
                for_each = ingress_security_rules.value.tcp_options != null ? [1] : []
                content {
                    min = ingress_security_rules.value.tcp_options.min
                    max = ingress_security_rules.value.tcp_options.max
                    
                    dynamic "source_port_range"{
                        for_each = ingress_security_rules.value.tcp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = ingress_security_rules.value.tcp_options.source_port_range.min
                            max = ingress_security_rules.value.tcp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "udp_options" {
                for_each = ingress_security_rules.value.udp_options != null ? [1] : []
                content {
                    min = ingress_security_rules.value.udp_options.min
                    max = ingress_security_rules.value.udp_options.max
                    dynamic "source_port_range"{
                        for_each = ingress_security_rules.value.udp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = ingress_security_rules.value.udp_options.source_port_range.min
                            max = ingress_security_rules.value.udp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "icmp_options" {
                for_each = ingress_security_rules.value.icmp_options != null ? [1] : []
                content {
                    type = ingress_security_rules.value.icmp_options.type
                    code = ingress_security_rules.value.icmp_options.code
                }
            } 

        }
    } 

    # Rule. Give access to lifecycle to configuration author.
    lifecycle {
        ignore_changes = [
            defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
        ]
    }
}


# When data is not loaded from TF side VCN management code,
# load vcn details for networks required by default SL.
# used by oci_core_default_security_list sl_set resource

# output vcns {
#     value = data.oci_core_vcn.vcns
# }
data "oci_core_vcn" "vcns" {
    for_each = local.load_data.vcn ? {} : {for key, value in local.sl_deploy_default : dirname(key) => value.vcn_id }

    vcn_id = each.value
}

# output sl_default_deploy {
#     value = local.sl_deploy_default
# }
resource "oci_core_default_security_list" "sl_set" {
    for_each = local.create_sl ? local.sl_deploy_default : {}

    # Rule. Make it possible to lookup resource by ocid via data source or loaded map
    manage_default_resource_id = local.load_data.vcn ? local.oci.vcn[each.value.vcn_fqn].default_security_list_id : data.oci_core_vcn.vcns[each.value.vcn_fqn].default_security_list_id

    compartment_id = each.value.compartment_id 
    
    display_name = each.value.sl_name

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    dynamic "egress_security_rules" {
        for_each =  each.value.egress_rules #module.sl_lang.sl_tf_egress[each.value.sl_name].rules
        content {
            description = egress_security_rules.value.description
            destination = egress_security_rules.value.destination
            destination_type = egress_security_rules.value.destination_type
            protocol = egress_security_rules.value.protocol
            stateless = egress_security_rules.value.stateless

            dynamic "tcp_options" {
                for_each = egress_security_rules.value.tcp_options != null ? [1] : []
                content {
                    min = egress_security_rules.value.tcp_options.min
                    max = egress_security_rules.value.tcp_options.max
                    
                    dynamic "source_port_range"{
                        for_each = egress_security_rules.value.tcp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = egress_security_rules.value.tcp_options.source_port_range.min
                            max = egress_security_rules.value.tcp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "udp_options" {
                for_each = egress_security_rules.value.udp_options != null ? [1] : []
                content {
                    min = egress_security_rules.value.udp_options.min
                    max = egress_security_rules.value.udp_options.max
                    dynamic "source_port_range"{
                        for_each = egress_security_rules.value.udp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = egress_security_rules.value.udp_options.source_port_range.min
                            max = egress_security_rules.value.udp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "icmp_options" {
                for_each = egress_security_rules.value.icmp_options != null ? [1] : []
                content {
                    type = egress_security_rules.value.icmp_options.type
                    code = egress_security_rules.value.icmp_options.code
                }
            } 

        }
    } 
    
    dynamic "ingress_security_rules" {
        for_each =  each.value.ingress_rules #module.sl_lang.sl_tf_ingress[each.value.sl_name].rules
        content {
            description = ingress_security_rules.value.description
            source = ingress_security_rules.value.source
            source_type = ingress_security_rules.value.source_type
            protocol = ingress_security_rules.value.protocol
            stateless = ingress_security_rules.value.stateless
            
            dynamic "tcp_options" {
                for_each = ingress_security_rules.value.tcp_options != null ? [1] : []
                content {
                    min = ingress_security_rules.value.tcp_options.min
                    max = ingress_security_rules.value.tcp_options.max
                    
                    dynamic "source_port_range"{
                        for_each = ingress_security_rules.value.tcp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = ingress_security_rules.value.tcp_options.source_port_range.min
                            max = ingress_security_rules.value.tcp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "udp_options" {
                for_each = ingress_security_rules.value.udp_options != null ? [1] : []
                content {
                    min = ingress_security_rules.value.udp_options.min
                    max = ingress_security_rules.value.udp_options.max
                    dynamic "source_port_range"{
                        for_each = ingress_security_rules.value.udp_options.source_port_range.max != null ? [1] : []
                        content {
                            min = ingress_security_rules.value.udp_options.source_port_range.min
                            max = ingress_security_rules.value.udp_options.source_port_range.max
                        }
                    }
                }
            }

            dynamic "icmp_options" {
                for_each = ingress_security_rules.value.icmp_options != null ? [1] : []
                content {
                    type = ingress_security_rules.value.icmp_options.type
                    code = ingress_security_rules.value.icmp_options.code
                }
            } 

        }
    } 

    lifecycle {
        ignore_changes = [
            defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
        ]
    }
}
