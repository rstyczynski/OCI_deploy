variable list {
    default = ["A", "B", "C"]

    type = list(string)
}

locals {

    list2list = [
        for v in var.list: v
    ]

    list2map = {
        for ndx, v in var.list: ndx => v
    }

    list2objects= [
        for ndx, v in var.list:{ 
            ndx = ndx
            value: v 
        }
    ]
}

output list2list {
    value = local.list2list
}

output list2map {
    value = local.list2map
}

output list2objects {
    value = local.list2objects
}

variable map {
    default = {
        letter1 = "A"
        letter2 = "B" 
        letter3 = "C"
    }

    type = map(string)
}

locals {

    map2list = [
        for k, v in var.map: v
    ]

    map2map = {
        for k, v in var.map: k => v
    }

    map2objects= [
        for k, v in var.map: { 
            k = k
            value: v 
        }
    ]
}

output map2list {
    value = local.map2list
}

output map2map {
    value = local.map2map
}

output map2objects {
    value = local.map2objects
}
