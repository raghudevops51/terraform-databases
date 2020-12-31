data "aws_ami" "ami" {
  owners            = ["973714476881"] // No need to change this here
  most_recent       = true
  name_regex        = "^Centos-7-DevOps-Practice"
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket          = var.bucket
    key             = "vpc/${var.ENV}/terraform.tfstate"
    region          = "us-east-2"
  }
}

data "aws_secretsmanager_secret" "creds" {
  name              = "roboshop"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = data.aws_secretsmanager_secret.creds.id
}
