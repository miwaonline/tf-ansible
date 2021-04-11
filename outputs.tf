output "apiinstance_ids" {
  description = "IDs of EC2 API instances"
  value       = aws_instance.appserver.*.id
}

output "webinstance_ids" {
  description = "IDs of EC2 web instances"
  value       = aws_instance.webserver.*.id
}


resource "local_file" "AnsibleInventory" {
 content = templatefile("inventory.template",
 {
  webservers = aws_instance.webserver.*.private_ip,
  appservers = aws_instance.appserver.*.private_ip
 }
 )
 filename = "inventory"
}
