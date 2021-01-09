provider "aws" {
    region = "us-west-1"
}

variable "ami_id" {
}

resource "aws_launch_configuration" "as_conf" {
    name_prefix = "launch-config-pyapp-"
    image_id = var.ami_id
    instance_type = "t3a.small"
    lifecycle {
        create_before_destroy = true
    }
    
}