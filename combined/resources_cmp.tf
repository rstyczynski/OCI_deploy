
#
#  create resources
#

// output "compartments_full" {
//     value = local.compartments_full
// }

// output "level1_compartments" {
//   value = local.level1_compartments
// }
resource "oci_identity_compartment" "level1_compartments" {
  # Rule. Module resource creation is conditional
  for_each = local.create_compartment ? local.level1_compartments : {}

  compartment_id = module.cfg.ocids["/"]

  name = local.compartments_full[each.key].name
  
  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete
  
  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags
  
  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

// output "level2_compartments" {
//   value = local.level2_compartments
// }
resource "oci_identity_compartment" "level2_compartments" {
  for_each = local.create_compartment ? local.level2_compartments : {}

  compartment_id = can(oci_identity_compartment.level1_compartments[local.compartments_full[each.key].parent_compartment_fqn].id) ? oci_identity_compartment.level1_compartments[local.compartments_full[each.key].parent_compartment_fqn].id : local.ocids[local.compartments_full[each.key].compartment]

  name = local.compartments_full[each.key].name

  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete

  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

// output "level3_compartments" {
//   value = local.level3_compartments
// }
resource "oci_identity_compartment" "level3_compartments" {
  for_each = local.create_compartment ? local.level3_compartments : null

  compartment_id = can(oci_identity_compartment.level2_compartments[local.compartments_full[each.key].parent_compartment_fqn].id) ? oci_identity_compartment.level2_compartments[local.compartments_full[each.key].parent_compartment_fqn].id : local.ocids[local.compartments_full[each.key].compartment]

  name = local.compartments_full[each.key].name

  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete

  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

// output "level4_compartments" {
//   value = local.level4_compartments
// }
resource "oci_identity_compartment" "level4_compartments" {
  for_each = local.create_compartment ? local.level4_compartments : {}

  compartment_id = can(oci_identity_compartment.level3_compartments[local.compartments_full[each.key].parent_compartment_fqn].id) ? oci_identity_compartment.level3_compartments[local.compartments_full[each.key].parent_compartment_fqn].id : local.ocids[local.compartments_full[each.key].compartment]

  name = local.compartments_full[each.key].name

  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete

  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

// output "level5_compartments" {
//   value = local.level5_compartments
// }
resource "oci_identity_compartment" "level5_compartments" {
  for_each = local.create_compartment ? local.level5_compartments : {}

  compartment_id = can(oci_identity_compartment.level4_compartments[local.compartments_full[each.key].parent_compartment_fqn].id) ? oci_identity_compartment.level4_compartments[local.compartments_full[each.key].parent_compartment_fqn].id : local.ocids[local.compartments_full[each.key].compartment]

  name = local.compartments_full[each.key].name

  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete

  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

// output "level6_compartments" {
//   value = local.level6_compartments
// }
resource "oci_identity_compartment" "level6_compartments" {
  for_each = local.create_compartment ? local.level6_compartments : {}

  compartment_id = can(oci_identity_compartment.level5_compartments[local.compartments_full[each.key].parent_compartment_fqn].id) ? oci_identity_compartment.level5_compartments[local.compartments_full[each.key].parent_compartment_fqn].id : local.ocids[local.compartments_full[each.key].compartment]

  name = local.compartments_full[each.key].name

  description = local.compartments_full[each.key].description
  enable_delete = local.compartments_full[each.key].enable_delete

  freeform_tags = local.compartments_full[each.key].freeform_tags
  defined_tags = local.compartments_full[each.key].defined_tags

  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}

