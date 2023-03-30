variable "security_group" {
  description = "Name of the security group for web server"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instances to run (e.g. t2.micro)"
  type        = string
}

variable "environment_name" {
  description = "name of environment to deploy"
  type        = string
}