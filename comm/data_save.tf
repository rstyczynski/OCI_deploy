
#
# save information about objects
#

#
# data save to a local file
#
resource "null_resource" "store_created_objects_cmp" {
  count = local.data_interface == "file" ? 1 : 0

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<-EOF
        cat << EOFJSON > ${local.egress_objects.folder.created_data}/${local.created_objects_name}.json
    ${jsonencode(local.created_objects)}
    EOFJSON
    EOF
  }
}

#
# data save to an object storage
#
#data "oci_objectstorage_namespace" "os_namespace" {}
resource "oci_objectstorage_object" "created_objects" {
  count = local.data_interface == "bucket" ? 1 : 0

  namespace    = data.oci_objectstorage_namespace.os_namespace.namespace
  bucket       = local.egress_remote_objects.bucket
  object       = "${local.egress_remote_objects.folder.created_data}/${local.created_objects_name}.json"
  content_type = "application/json"
  content      = jsonencode(local.created_objects)
}
