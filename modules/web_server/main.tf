locals {
  http_port = 80
  https_port = 443
  any_port = 0
  all_ips      = ["0.0.0.0/0"]
  tcp_protocol = "tcp"
}

resource "aws_instance" "hello_server" {
  ami           = "ami-0055e70f580e9ae80"
  # instance_type = "t2.micro"
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.example_security_group.id]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>Hello World from $(hostname -f)!</h1><div>Our users: $(aws iam list-users)</div></body></html>" > /var/www/html/index.html
              EOF
  user_data_replace_on_change = true

  tags = {
    Name = "${var.environment_name}-hello"
  }

  iam_instance_profile = aws_iam_instance_profile.iam_readonly_profile.name
}

resource "aws_security_group" "example_security_group" {
  # id          = "example-security-group-id"
  name_prefix = "${var.security_group}-group"
  # name_prefix = "example-security-group"
  description = "Example security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  ingress {
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = "-1"
    cidr_blocks = local.all_ips
  }

  tags = {
    Name = "example-security-group"
  }
}

# Resources to list iam users

resource "aws_iam_instance_profile" "iam_readonly_profile" {
  name = "${var.environment_name}_example_instance_profile"

  role = aws_iam_role.iam_readonly_role.name
}

resource "aws_iam_role" "iam_readonly_role" {
  name = "${var.environment_name}_iam_readonly_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iam_readonly_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  role       = aws_iam_role.iam_readonly_role.name
}

