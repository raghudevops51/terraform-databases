resource "aws_instance" "instance" {
  ami               = data.aws_ami.ami.id
  instance_type     = var.INSTANCE_TYPE
  key_name          = var.KEY_NAME
  subnet_id         = data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNETS[0]
  vpc_security_group_ids = [aws_security_group.allow-db.id]
  tags                    = {
    Name                  = var.component
  }
}

resource "null_resource" "apply" {
  provisioner "remote-exec" {
    connection {
      host      = aws_instance.instance.private_ip
      user      = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_USER"]
      password  = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["SSH_PASS"]
    }
    inline = [
      "sudo pip install ansible",
      "echo localhost >/tmp/hosts",
      "ansible-pull -i /tmp/hosts -U https://DevOps-Batches@dev.azure.com/DevOps-Batches/DevOps51/_git/ansible roboshop.yml -t ${var.component} -e component=${var.component} -e PAT=${jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)["PAT"]} -e ENV=${var.ENV}"
    ]
  }
}

resource "aws_security_group" "allow-db" {
  name        = "allow-for-${var.component}"
  description = "allow-for-${var.component}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = var.PORT
    to_port     = var.PORT
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.VPC_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-for-${var.component}"
  }
}

resource "aws_route53_record" "dns-records" {
  name                = "${var.component}-${var.ENV}.devopsb51.tk"
  type                = "A"
  zone_id             = data.terraform_remote_state.vpc.outputs.HOSTED_ZONE_ID
  ttl                 = "300"
  records             = [aws_instance.instance.private_ip]
}
