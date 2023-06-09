terraform {
  backend "s3" {
    bucket = "dev-mhakimov-saa"
    key = "terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "web_server"{
    source = "../../modules/web_server"
    security_group = "dev-sg"
    instance_type = "t2.nano"
    environment_name = "dev"
}