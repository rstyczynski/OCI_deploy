data "local_file" hello {
  for_each = toset(["/Users/rstyczynski/hello.txt"])

  filename = each.value
}

output "name" {
  value = data.local_file.hello["/Users/rstyczynski/hello.txt"].content
}
