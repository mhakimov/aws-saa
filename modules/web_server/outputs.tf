output "az" {
  value       = aws_instance.hello_server.availability_zone
  description = "Availability zone of EC2 server"
}