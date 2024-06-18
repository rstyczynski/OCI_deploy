locals {
    labels = {
        label1 = "a"
        label2 = "b;c"
    }

    acl = [
        "Hello label1",
        "Hello label2"
    ]
}

locals {
  labels_map = {
    for key, value in local.labels : key => split(";", value)
  }

  transformed_acl = [
    for acl in local.acl : [
        for label_id, labels_list in local.labels_map : [
                for label_value in labels_list : [
                    replace(acl, label_id, label_value)
                ]
            ] if regex("Hello (\\w+)", acl)[0] == label_id
    ]
  ]
}

output labels_map {
    value = local.labels_map
}

output transformed_acl {
    value = flatten(local.transformed_acl)
}
