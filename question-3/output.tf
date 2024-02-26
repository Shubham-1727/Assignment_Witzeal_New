output "InstanceId" {
  value = aws_instance.test.id
}

output "PublicIpAddress" {
  value = aws_instance.test.public_ip
}
