output "serviceName" {
  value = "${module.vpc.serviceName}"
}

output "vpcId" {
  value = "${module.vpc.vpcId}"
}

output "instancePrivateSubnets" {
  value = "${module.vpc.instancePrivateSubnets}"
}

output "cidr_PrivateSubnets" {
  value = "${module.vpc.cidr_PrivateSubnets}"
}

output "instancePublicSubnets" {
  value = "${module.vpc.instancePublicSubnets}"
}

output "cidr_PublicSubnets" {
  value = "${module.vpc.cidr_PublicSubnets}"
}

output "ELB_DNS_Name" {
  value = "${module.webInstances.load_balancer_dns_name}"
}
