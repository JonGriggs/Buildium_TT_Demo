data "aws_availability_zones" "available" {}

## Load Balancer to sit in front of the servers
resource "aws_lb" "ServerLB" {
  name            = "${var.serviceName}-${var.role}LB"
  internal        = false
  security_groups = ["${aws_security_group.LoadBalSG.id}"]
  subnets         = ["${var.pubSubnetA}", "${var.pubSubnetB}"]

  tags {
    Name = "${var.serviceName}-${var.role}LB"
  }

  tags {
    ServiceName = "${var.serviceName}"
  }
}

resource "aws_lb_target_group" "Server_targetGroup" {
  name     = "${var.serviceName}-${var.role}-HTTP-TargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpcId}"

  health_check = {
    interval            = 10
    matcher             = "200"
    path                = "/"
    port                = "80"
    timeout             = 9
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
  }

  tags {
    Name = "${var.serviceName}-HTTP-TargetGroup"
  }

  tags {
    ServiceName = "${var.serviceName}"
  }
}

resource "aws_lb_listener" "Server_httplistener" {
  load_balancer_arn = "${aws_lb.ServerLB.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.Server_targetGroup.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "Server_tgroupAttach" {
  count            = "${var.numinstances}"
  target_group_arn = "${aws_lb_target_group.Server_targetGroup.arn}"
  target_id        = "${element(aws_instance.instance.*.id, count.index)}"
  port             = 80
}

resource "aws_instance" "instance" {
  count         = "${var.numinstances}"
  ami           = "${var.amiId}"
  instance_type = "${var.instanceType}"

  availability_zone           = "${data.aws_availability_zones.available.names[count.index]}"
  associate_public_ip_address = "false"
  vpc_security_group_ids      = ["${aws_security_group.instanceSG.id}"]
  key_name                    = "${var.serverKey}"

  subnet_id = "${element(list(var.privSubnetA, var.privSubnetB), count.index)}"

  user_data = "${var.user_data}"

  lifecycle {
    ignore_changes = "user_data"
  }

  tags {
    Name = "${var.serviceName}-${var.role}${count.index + 1}"
  }

  tags {
    ServerType = "${var.role}"
  }

  tags {
    ServiceName = "${var.serviceName}"
  }
}

resource "aws_security_group" "instanceSG" {
  name        = "${var.serviceName}_${var.role}_Security_Group"
  description = "Allow basic server functionality"
  vpc_id      = "${var.vpcId}"

  tags {
    Name = "${var.serviceName}_${var.role}_Security_Group"
  }
  tags {
    ServiceName = "${var.serviceName}"
  }
}

resource "aws_security_group_rule" "httpFromLb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.LoadBalSG.id}"

  security_group_id = "${aws_security_group.instanceSG.id}"
  description = "LB to webserver http by security group"
}
resource "aws_security_group_rule" "egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.instanceSG.id}"
}

resource "aws_security_group" "LoadBalSG" {
  name        = "${var.serviceName}-${var.role}_Load_Balancer_Security_Group"
  description = "Allows web traffic from the internet to the load balancers"
  vpc_id      = "${var.vpcId}"

  tags {
    Name = "${var.serviceName}-${var.role}_Load_Balancer_Security_Group"
  }
  tags {
    ServiceName = "${var.serviceName}"
  }
}

resource "aws_security_group_rule" "https-public" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.LoadBalSG.id}"
  description = "Internet to load balancer https"
}

resource "aws_security_group_rule" "http-public" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.LoadBalSG.id}"
  description = "Internet to load balancer http"
}

resource "aws_security_group_rule" "egress-public" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.LoadBalSG.id}"
}