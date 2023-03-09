output "public_ip" {
  value = aws_instance.dev_node.public_ip
}



output "private_ip" {
  value = aws_instance.dev_node.private_ip
}