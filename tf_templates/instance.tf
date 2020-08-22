provider "aws" {
  region  = var.region
  profile = var.profile
}

resource "aws_vpc" "web_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "web_vpc"
  }
}

resource "aws_subnet" "web_public_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = var.subnet_public_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = var.subnet_zone
  tags = {
    Name = "web_public_subnet"
  }
}

resource "aws_subnet" "web_public_subnet_2" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = var.subnet_public_cidr_2
  map_public_ip_on_launch = "true"
  availability_zone       = var.subnet_zone_2
  tags = {
    Name = "web_public_subnet_2"
  }
}

resource "aws_subnet" "web_private_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = var.subnet_private_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.subnet_zone
  tags = {
    Name = "web_private_subnet"
  }
}

resource "aws_internet_gateway" "web_internet-gw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "web_internet-gw"
  }
}

resource "aws_route_table" "web_public-rt" {
  vpc_id = aws_vpc.web_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_internet-gw.id
  }
}

resource "aws_route_table_association" "web_public-rta" {
  subnet_id      = aws_subnet.web_public_subnet.id
  route_table_id = aws_route_table.web_public-rt.id
}

resource "aws_route_table_association" "web_public-rta_2" {
  subnet_id      = aws_subnet.web_public_subnet_2.id
  route_table_id = aws_route_table.web_public-rt.id
}
resource "aws_eip" "web_nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "web_nat-gw" {
  allocation_id = aws_eip.web_nat_eip.id
  subnet_id     = aws_subnet.web_public_subnet.id
  depends_on    = [aws_internet_gateway.web_internet-gw]
}

resource "aws_route_table" "web_private-rt" {
  vpc_id = aws_vpc.web_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.web_nat-gw.id
  }
}

resource "aws_route_table_association" "web_private-rta" {
  subnet_id      = aws_subnet.web_private_subnet.id
  route_table_id = aws_route_table.web_private-rt.id
}


resource "aws_security_group" "web_SG" {
  name        = var.sg_name
  description = "web server security group"
  vpc_id      = aws_vpc.web_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webserver SG"
  }
}

resource "aws_security_group_rule" "web_SG_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_SG.id
}

resource "aws_security_group_rule" "web_SG_rule_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_SG.id
}

resource "aws_security_group" "bastion_SG" {
  name        = var.bastion_sg_name
  description = "bastion server security group"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
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
    Name = "bastion-host-SG"
  }
}



resource "aws_key_pair" "web_keypair" {
  key_name   = "web_key"
  public_key = file(var.public_key)
}

resource "aws_instance" "bastion_server" {
  ami           = "ami-0bbe28eb2173f6167"
  instance_type = var.bastion_instance_type
  key_name      = aws_key_pair.web_keypair.key_name
  subnet_id     = aws_subnet.web_public_subnet.id
  vpc_security_group_ids = [
    aws_security_group.bastion_SG.id
  ]
  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  tags = {
    Name = "bastion-host"
  }
}

resource "aws_instance" "web_servers" {
  count         = 2
  ami           = "ami-0bbe28eb2173f6167"
  instance_type = var.instance_type
  key_name      = aws_key_pair.web_keypair.key_name
  subnet_id     = aws_subnet.web_private_subnet.id
  vpc_security_group_ids = [
    aws_security_group.web_SG.id
  ]
  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_size           = 30
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

  tags = {
    Name = "WebServers-${count.index}"
  }
}

resource "local_file" "inven" {
  content = templatefile("init.tpl",
    {
      ip_address = join("\n", aws_instance.web_servers.*.private_ip)
    }
  )
  filename = "inventory"
}

resource "local_file" "ssh_config" {
  content = templatefile("ssh.tpl",
    {
      bastion_host = aws_instance.bastion_server.public_ip
      host_range   = var.subnet_private_ip_range
      private_key  = var.private_key
    }
  )
  filename = "ssh_config"
}

resource "null_resource" "trigger_ansible" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = "ansible-playbook ansible/nginx_install.yml -i inventory"
  }
}
