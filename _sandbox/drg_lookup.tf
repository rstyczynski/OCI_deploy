

data "oci_core_drg_attachments" "all" {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaav7h4eo6ejfb6b2fqshljmfcj2jeqite5fp5bot3hi45rwcdxbrra"
  drg_id         = "ocid1.drg.oc1.me-dubai-1.aaaaaaaacey7wz67kdg5bl522xvkpac4oe4arpsxblbxz3ie7sooc4i4qlpa"   
  //attachment_type = "VCN"

}

locals {
  drg_vcn_attachments = [ 
    for record in data.oci_core_drg_attachments.all.drg_attachments :
      {
        "${record.network_details[0].id}" = {
          id = record.id
          display_name = record.display_name

          vcn_id = record.network_details[0].id
          vcn_route_type = record.network_details[0].vcn_route_type

          drg_id = record.drg_id
          drg_route_table_id = record.drg_route_table_id
          export_drg_route_distribution_id = record.export_drg_route_distribution_id
          remove_export_drg_route_distribution_trigger = record.remove_export_drg_route_distribution_trigger
          is_cross_tenancy = record.is_cross_tenancy

          defined_tags = record.defined_tags
          freeform_tags = record.freeform_tags

          compartment_id =  record.compartment_id

          state = record.state
          time_created = record.time_created

        }
      } if record.network_details[0].type == "VCN"
  ]
}

output "drg_vcn_attachments" {
  // Output VCN attachments
  value = local.drg_vcn_attachments
}

output "drg_id_attachments" {
  // Output VCN attachments
  value = data.oci_core_drg_attachments.all
}