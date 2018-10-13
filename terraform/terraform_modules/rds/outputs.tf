output "rdsEndpoint" {
    value = "${aws_rds_cluster.auroraCluster.endpoint}"
}