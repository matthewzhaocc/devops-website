provider "aws" {
    region = "us-west-1"
}

variable "ami_id" {
}

resource "aws_vpc" "pyapp_vpc" {
    cidr_block = "172.30.0.0/16"
}

resource "aws_subnet" "web1" {
    vpc_id = aws_vpc.pyapp_vpc.id
    cidr_block = "172.30.0.0/24"
    instance_tenancy = "default"
}
resource "aws_subnet" "web2" {
    vpc_id = aws_vpc.pyapp_vpc.id
    cidr_block = "172.30.1.0/24"
    instance_tenancy = "default"
}
resource "aws_subnet" "lb1" {
    vpc_id = aws_vpc.pyapp_vpc.id
    cidr_block = "172.30.2.0/24"
    instance_tenancy = "default"
}
resource "aws_subnet" "lb2" {
    vpc_id = aws_vpc.pyapp_vpc.id
    cidr_block = "172.30.3.0/24"
    instance_tenancy = "default"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.pyapp_vpc.id
}

resource "aws_route_table" "main_table" {
    vpc_id = aws_vpc.pyapp_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "asso_web1" {
    subnet_id = aws_subnet.web1.id
    route_table_id = aws_route_table.main_table.id
}

resource "aws_route_table_association" "asso_web2" {
    subnet_id = aws_subnet.web2.id
    route_table_id = aws_route_table.main_table.id
}

resource "aws_route_table_association" "asso_lb1" {
    subnet_id = aws_subnet.lb1.id
    route_table_id = aws_route_table.lb1.id
}
resource "aws_route_table_association" "asso_lb1" {
    subnet_id = aws_subnet.lb2.id
    route_table_id = aws_route_table.lb2.id
}
resource "aws_security_group" "web_sg" {
    name = "websg"
    description = "sg for webservers"
    vpc_id = aws_vpc.pyapp_vpc.id
}
resource "aws_security_group_rule" "allow_from_lb" {
    type = "ingress"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_group_id = aws_security_group.web_sg.id
    source_security_group_id = aws_security_group.alb_sg.id
}
resource "aws_security_group" "alb_sg" {
    name = "albsg"
    description = "sg for lbs"
    vpc_id = aws_vpc.pyapp_vpc.id
    ingress {
        description = "HTTPs Traffic"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

    }

    ingress {
        description = "HTTP Traffic"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        tp_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/9"]
    }
}
resource "aws_launch_configuration" "as_conf" {
    name_prefix = "launch-config-pyapp-"
    image_id = var.ami_id
    instance_type = "t3a.small"
    lifecycle {
        create_before_destroy = true
    }
    security_groups = [aws_security_group.web_sg.id]
}

resource "aws_autoscaling_group" "scale_web" {
    name = "scalewebservers"
    max_size = 10
    min_size = 2
    health_check_grace_period = 300
    health_check_type = "ELB"
    desired_capacity = 2
    force_delete = true
    launch_configuration = aws_launch_configuration.as_conf.name
    vpc_zone_identifier = [aws_subnet.web1.id, aws_subnet.web2.id]
}

resource "aws_lb" "lb_ingress" {
    name = "lb_ingress"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.alb_sg.id]
    subnets = [aws_subnet.lb1.id, aws_subnet.lb2.id]
    enable_deletion_protection = false


}

resource "aws_lb_target_group" "http_tg_pyapp" {
    name = "http_target"
    port = 8080
    protocol = "HTTP"
    vpc_id = aws_vpc.pyapp_vpc.id
}

resource "aws_lb_target_group_attachment" "tg_attachment_alb" {
    target_group_arn = aws_lb_target_group.http_tg_group.arn
    target_id = 
}