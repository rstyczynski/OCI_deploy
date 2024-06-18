
#
#  create resources
#

# Rule. Keep output ready to debug resource creation
# output rt_deploy {
#     value = local.rt_deploy
# }
resource "oci_core_route_table" "rt_vcn_set" {
    for_each = local.create_rt ? local.rt_deploy : {}

    compartment_id = each.value.compartment_id
    vcn_id = each.value.vcn_id
    display_name = each.value.display_name

    dynamic "route_rules" { 
        for_each = each.value.route_rules
        content {

        destination = route_rules.value.destination
        destination_type = route_rules.value.destination_type

        network_entity_id = route_rules.value.gateway_id

        description = route_rules.value.description
        }
    }

    defined_tags = each.value.defined_tags
    freeform_tags = each.value.freeform_tags

    # Rule. Give access to lifecycle to configuration author.
    lifecycle {
        ignore_changes = [
            defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
        ]

        # Rule. Block resource creation in case of detected errors.
        precondition {
          condition = local.rt_errors == {}

          error_message = "Route table key must follow FQN naming. Errored keys are: ${jsonencode(local.rt_errors)}"
        }

        precondition {
          condition = module.rt_lang[each.key].rt_errors == {}

          error_message = "Route table errors detected: ${each.key} => ${jsonencode(module.rt_lang[each.key].rt_errors)}"
        }
    }
}

