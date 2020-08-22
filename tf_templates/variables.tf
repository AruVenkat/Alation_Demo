variable "region" {
    default = "us-east-2"
}

variable "subnet_zone" {
    default = "us-east-2a"
}

variable "subnet_zone_2" {
    default = "us-east-2b"
}
variable "profile" {
    default = "default"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}

variable "subnet_public_cidr" {
    default = "10.0.1.0/24"
}

variable "subnet_public_cidr_2" {
    default = "10.0.3.0/24"
}

variable "subnet_private_ip_range" {
    default = "10.0.2.*"
}

variable "subnet_private_cidr" {
    default = "10.0.2.0/24"
}

variable "sg_name" {
    default = "web_security_group"
}

variable "bastion_sg_name" {
    default = "bastion_security_group"
}

variable "ami" {
    default = "ami-04adf33460efc8798"
}

variable "instance_type" {
    default =  "t2.micro"
}

variable "bastion_instance_type" {
    default = "t2.micro"
}

variable "key_name" {
    default =  "poc"
}
variable "public_key" {
    default = "/home/ubuntu/.ssh/web.pub"
}

variable "private_key" {
    default = "/home/ubuntu/.ssh/web"
}
