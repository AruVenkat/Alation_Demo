resource "aws_security_group" "loadbalancer_SG" {
  name        = "LB_SG"
  description = "Classic LB security group"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
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
    Name = "Classic-LB-SG"
  }
}

resource "aws_elb" "lb" {
  name            = "webserver-elb"
  subnets         = [aws_subnet.web_public_subnet.id]
  security_groups = [aws_security_group.loadbalancer_SG.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    target              = "HTTP:80/"
    interval            = 30
  }

  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
  instances                   = aws_instance.web_servers.*.id
  tags = {
    Name = "webserver-elb"
  }
}
