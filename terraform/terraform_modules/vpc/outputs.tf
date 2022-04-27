output "serviceName" {
  value = var.serviceName
}

output "vpcId" {
  value = aws_vpc.vpc.id
}

output "instancePrivateSubnets" {
  value = [aws_subnet.AZa_privateSubnet.id, aws_subnet.AZb_privateSubnet.id]
}

output "cidr_PrivateSubnets" {
  value = [aws_subnet.AZa_privateSubnet.cidr_block, aws_subnet.AZb_privateSubnet.cidr_block]
}

output "instancePublicSubnets" {
  value = [aws_subnet.AZa_publicSubnet.id, aws_subnet.AZb_publicSubnet.id]
}

output "cidr_PublicSubnets" {
  value = [aws_subnet.AZa_publicSubnet.cidr_block, aws_subnet.AZb_publicSubnet.cidr_block]
}

