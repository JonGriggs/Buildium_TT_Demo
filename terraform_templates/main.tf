provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "vpc" {
  source = "../terraform_modules/vpc"

  serviceName = "${var.serviceName}"
}