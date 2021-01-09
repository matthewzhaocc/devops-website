variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "app_src" {
  access_key    = "${var.aws_access_key}"
  ami_name      = "pyapp ${local.timestamp}"
  instance_type = "t3a.micro"
  region        = "us-west-1"
  secret_key    = "${var.aws_secret_key}"
  source_ami    = "ami-09d9c5cdcfb8fc655"
  ssh_username  = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.app_src"]
  provisioner "ansible" {
    playbook_file = "./install..yml"
    user          = "ec2-user"
  }
}