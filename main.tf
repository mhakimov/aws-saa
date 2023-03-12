provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "hello_server" {
  ami           = "ami-0055e70f580e9ae80"
  instance_type = "t2.micro"
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
    Name = "hello"
  }

  iam_instance_profile = aws_iam_instance_profile.iam_readonly_profile.name
}

resource "aws_security_group" "example_security_group" {
  # id          = "example-security-group-id"
  name_prefix = "example-security-group"
  description = "Example security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-security-group"
  }
}

# Resources to list iam users

resource "aws_iam_instance_profile" "iam_readonly_profile" {
  name = "example_instance_profile"

  role = aws_iam_role.iam_readonly_role.name
}

resource "aws_iam_role" "iam_readonly_role" {
  name = "iam_readonly_role"

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

