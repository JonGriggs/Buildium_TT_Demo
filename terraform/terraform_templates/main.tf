provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "vpc" {
  source = "../terraform_modules/vpc"

  serviceName = "${var.serviceName}"
}

## Initialization script to be run as User Data
data "template_file" "init" {
  template = "${file("../../user_data/amazon_linux_bootstrap.sh")}"

  vars {
    dbString = "${module.database.rdsEndpoint}"
  }
}

module "webInstances" {
  source = "../terraform_modules/ec2-elb"

  amiId        = "${var.amiId}"
  instanceType = "${var.instanceType}"
  numinstances = "2"
  privSubnetA  = "${module.vpc.instancePrivateSubnets[0]}"
  privSubnetB  = "${module.vpc.instancePrivateSubnets[1]}"
  pubSubnetA   = "${module.vpc.instancePublicSubnets[0]}"
  pubSubnetB   = "${module.vpc.instancePublicSubnets[1]}"
  role         = "web"
  serverKey    = "${var.serverKey}"
  serviceName  = "${var.serviceName}"
  user_data    = "${data.template_file.init.rendered}"
  vpcId        = "${module.vpc.vpcId}"
}

module "database" {
  source = "../terraform_modules/rds"

  dbInstanceClass = "${var.dbInstanceClass}"
  privSubnetA  = "${module.vpc.instancePrivateSubnets[0]}"
  privSubnetB  = "${module.vpc.instancePrivateSubnets[1]}"
  RDS_password = "K3rnsPl4n3T"
  rds_security_groups = "${aws_security_group.dbAccess.id}"
  serviceName = "${var.serviceName}"
}

resource "aws_security_group" "dbAccess" {
  name        = "${var.serviceName}-mysql_connections"
  vpc_id      = "${module.vpc.vpcId}"
  description = "${var.serviceName} Security Group"
}

resource "aws_security_group_rule" "allow_cidr" {
  type        = "ingress"
  from_port   = 3307
  to_port     = 3307
  protocol    = "tcp"
  source_security_group_id = "${module.webInstances.instance_security_group}"

  security_group_id = "${aws_security_group.dbAccess.id}"
}