terraform {
  backend "s3" {
    bucket = "prod-mhakimov-saa"
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "web_server"{
    source = "../../modules/web_server"
    security_group = "prod-sg"
    instance_type = "t2.micro"
    environment_name = "prod"
}