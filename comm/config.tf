variable "data_interface" {
  default = "bucket"

  type = string

  validation {
    condition     = contains(["bucket", "file", "none"], var.data_interface)
    error_message = "Valid values are: bucket, file, none."
  }
}

variable load_data {
  default = {cmp: true, vcn: true}

  type = map(bool)
}

variable "egress_objects" {
  default = {
    folder = {
      created_data = "."
      compartment  = "../oci_identity_compartment"
      vcn          = "../oci_core_vcn"
    }
  }

  type = object({
    folder = object({
      created_data = string
      compartment  = string
      vcn          = string
    })
  })
}

variable "ingress_objects" {
  default = {
    folder = {
      created_data = "."
      compartment  = "../oci_identity_compartment"
      vcn          = "../oci_core_vcn"
    }
  }

  type = object({
    folder = object({
      created_data = string
      compartment  = string
      vcn          = string
    })
  })
}

variable "ingress_remote_objects" {
  default = {
    bucket = "bucket-20240412-2237"
    folder = {
      created_data = "oci/infra"
      vcn          = "oci/infra"
      compartment  = "oci/infra"
    }
  }

  type = object({
    bucket = string
    folder = object({
      created_data = string
      vcn          = string
      compartment  = string
    })
  })
}

variable "egress_remote_objects" {
  default = {
    bucket = "bucket-20240412-2237"
    folder = {
      created_data = "oci/infra"
      vcn          = "oci/infra"
      compartment  = "oci/infra"
    }
  }

  type = object({
    bucket = string
    folder = object({
      created_data = string
      vcn          = string
      compartment  = string
    })
  })
}

variable created_objects_name {}
variable created_objects {}

#
# core locals
#

locals {
  egress_objects         = var.egress_objects
  ingress_objects        = var.ingress_objects
  data_interface         = var.data_interface
  egress_remote_objects  = var.egress_remote_objects
  ingress_remote_objects = var.ingress_remote_objects

  load_data              = var.load_data

  created_objects_name = var.created_objects_name
  created_objects = var.created_objects
}
