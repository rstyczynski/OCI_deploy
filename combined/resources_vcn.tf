

#
#  create resources
#

// output vcns_full {
//   value = local.vcns_full
// }
resource "oci_core_vcn" "vcns" {
  for_each = local.create_vcn ? local.vcn_deploy : {}

  compartment_id = each.value.compartment_id
  display_name = each.value.display_name

  cidr_block = each.value.cidr_block
  dns_label = try(each.value.dns_label, basename(each.key))

  freeform_tags = each.value.freeform_tags
  defined_tags = each.value.defined_tags
  
  lifecycle {
    ignore_changes = [
      defined_tags["Oracle-Tags.CreatedBy"], defined_tags["Oracle-Tags.CreatedOn"]
    ]
  }
}
