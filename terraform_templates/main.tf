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
  template = "${file("../user_data/ec2_win_bootstrap.ps1")}"
}

module "webInstances" {
  source = "../terraform_modules/ec2-elb"

  amiId        = "${var.amiId}"
  instanceType = "${var.instanceType}"
  numinstances = "2"
  privsubnetA  = "${module.vpc.instancePrivateSubnets[0]}"
  privsubnetB  = "${module.vpc.instancePrivateSubnets[1]}"
  pubSubnetA   = "${module.vpc.instancePublicSubnets[0]}"
  pubSubnetB   = "${module.vpc.instancePublicSubnets[1]}"
  role         = "web"
  serverKey    = "${var.serverKey}"
  serviceName  = "${var.serviceName}"
  user_data    = "${data.template_file.init.rendered}"
  vpcId        = "${module.vpc.vpcId}"
}
