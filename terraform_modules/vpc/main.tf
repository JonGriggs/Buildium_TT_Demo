resource "aws_vpc" "vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "${var.serviceName}_VPC"
  }
}

## Define Subnets 

data "aws_availability_zones" "available" {}

resource "aws_subnet" "AZa_privateSubnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "172.16.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "${var.serviceName}-Private-Subnet-AZa"
  }
}

resource "aws_subnet" "AZb_privateSubnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "172.16.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "${var.serviceName}-Private-Subnet-AZb"
  }
}

resource "aws_subnet" "AZa_publicSubnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "172.16.3.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "${var.serviceName}-Public-Subnet-AZa"
  }
}

resource "aws_subnet" "AZb_publicSubnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "172.16.4.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"

  tags {
    Name = "${var.serviceName}-Public-Subnet-AZb"
  }
}


resource "aws_internet_gateway" "VpcIgw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.serviceName}-InternetGateway"
  }
}

resource "aws_eip" "AZa_nat_ip" {
  vpc = true
}

resource "aws_eip" "AZb_nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "AZa_nat_gw" {
  allocation_id = "${aws_eip.AZa_nat_ip.id}"
  subnet_id     = "${aws_subnet.AZa_publicSubnet.id}"

  tags {
    Name = "${var.serviceName}-${aws_subnet.AZa_privateSubnet.id}-NatGW"
  }
}

resource "aws_nat_gateway" "AZb_nat_gw" {
  allocation_id = "${aws_eip.AZb_nat_ip.id}"
  subnet_id     = "${aws_subnet.AZb_publicSubnet.id}"

  tags {
    Name = "${var.serviceName}-${aws_subnet.AZb_privateSubnet.id}-NatGW"
  }
}

## Route tables
resource "aws_route_table" "AZa-publicRoutes" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.VpcIgw.id}"
  }

  tags {
    Name = "${var.serviceName}-Public Subnet Route Table"
  }
}

resource "aws_route_table" "AZa-privateRoutes" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.AZa_nat_gw.id}"
  }

  tags {
    Name = "${var.serviceName}-Private Subnet Route Table-AZa"
  }
}

resource "aws_route_table" "AZb-privateRoutes" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.AZb_nat_gw.id}"
  }

  tags {
    Name = "${var.serviceName}-Private Subnet Route Table-AZb"
  }
}

## Route table associations

resource "aws_route_table_association" "Pub2btoPubRT" {
  subnet_id      = "${aws_subnet.AZa_publicSubnet.id}"
  route_table_id = "${aws_route_table.AZa-publicRoutes.id}"
}

resource "aws_route_table_association" "Pub2ctoPubRT" {
  subnet_id      = "${aws_subnet.AZb_publicSubnet.id}"
  route_table_id = "${aws_route_table.AZa-publicRoutes.id}"
}

resource "aws_route_table_association" "Priv2btoPrivRT" {
  subnet_id      = "${aws_subnet.AZa_privateSubnet.id}"
  route_table_id = "${aws_route_table.AZa-privateRoutes.id}"
}

resource "aws_route_table_association" "Priv2ctoPrivRT" {
  subnet_id      = "${aws_subnet.AZb_privateSubnet.id}"
  route_table_id = "${aws_route_table.AZb-privateRoutes.id}"
}
