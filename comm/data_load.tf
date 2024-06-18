
#
# read information about related objects
#

data "local_file" "load_compartment_data" {
  count = local.data_interface == "file" ? 1 : 0

  filename = "${local.ingress_objects.folder.compartment}/created_objects_compartments.json"
}

data "oci_objectstorage_namespace" "os_namespace" {}
data "oci_objectstorage_object" "created_objects_compartments" {
    count = local.data_interface == "bucket" ? 1 : 0
    
    namespace = data.oci_objectstorage_namespace.os_namespace.namespace
    bucket = local.ingress_remote_objects.bucket
    object = "${local.ingress_remote_objects.folder.compartment}/created_objects_compartments.json"
}

data "local_file" "load_vcn_data" {
    count = local.data_interface == "file" ? 1 : 0

    filename = "${local.ingress_objects.folder.vcn}/created_objects_vcns.json"
}

data "oci_objectstorage_object" "created_objects_vcns" {
    count = local.data_interface == "bucket" ? 1 : 0
    
    namespace = data.oci_objectstorage_namespace.os_namespace.namespace
    bucket = local.ingress_remote_objects.bucket
    object = "${local.ingress_remote_objects.folder.vcn}/created_objects_vcns.json"
}

locals {
  required_objects = {
    cmp = local.load_data["cmp"] ? local.data_interface == "file" ? jsondecode(data.local_file.load_compartment_data[0].content) : local.data_interface == "bucket" ? jsondecode(data.oci_objectstorage_object.created_objects_compartments[0].content) : null : null
    vcn = local.load_data["vcn"] ? local.data_interface == "file" ? jsondecode(data.local_file.load_vcn_data[0].content) : local.data_interface == "bucket" ? jsondecode(data.oci_objectstorage_object.created_objects_vcns[0].content) : null : null
  } 
}

