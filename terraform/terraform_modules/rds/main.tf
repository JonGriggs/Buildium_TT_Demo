## Create Subnet Group

resource "aws_db_subnet_group" "private" {
  name        = "${lower(var.serviceName)}_private_subnets"
  subnet_ids  = ["${var.privSubnetA}", "${var.privSubnetB}"]
  description = "${var.serviceName} Subnet Group"

  tags {
    Name = "${var.serviceName}-RDS Subnet Group"
  }
}

## Encrypt the DB with a service-specific key
resource "aws_kms_key" "auroraClusterKey" {
  description = "${var.serviceName}-RDS-key"
}

resource "aws_kms_alias" "clusterKeyAlias" {
  name          = "alias/${var.serviceName}-RDS"
  target_key_id = "${aws_kms_key.auroraClusterKey.key_id}"
}

## Create Aurora Cluster 

resource "aws_rds_cluster" "auroraCluster" {
  count = "1"

  cluster_identifier = "${lower(var.serviceName)}-aurora"
  engine             = "aurora-mysql"

  storage_encrypted = true
  kms_key_id        = "${aws_kms_key.auroraClusterKey.arn}"

  backup_retention_period         = "1"
  preferred_backup_window         = "01:00-04:00"
  apply_immediately               = true
  vpc_security_group_ids          = ["${var.rds_security_groups}"]
  master_username                 = "rdsuser"
  master_password                 = "${var.RDS_password}"
  db_subnet_group_name            = "${aws_db_subnet_group.private.name}"
  skip_final_snapshot             = true

  tags {
    Name        = "${var.serviceName} Aurora Cluster"
  }

  lifecycle {
    create_before_destroy = true
  }
}

## Aurora instance
resource "aws_rds_cluster_instance" "ServiceInstance" {
  count = "1"

  cluster_identifier      = "${aws_rds_cluster.auroraCluster.id}"
  identifier              = "${lower(var.serviceName)}-db0${count.index + 1}"
  instance_class          = "${var.dbInstanceClass}"
  db_subnet_group_name    = "${aws_db_subnet_group.private.name}"
  engine                  = "aurora-mysql"

  tags {
    Name = "${var.serviceName}-db0${count.index + 1}"
  }

  lifecycle {
    create_before_destroy = false
  }
}
