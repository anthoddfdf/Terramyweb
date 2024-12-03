output "publicip" {
    value = aws_instance.njinx_server.associate_public_ip_address
  
}
output "az" {
    value = aws_instance.njinx_server.availability_zone
  
}