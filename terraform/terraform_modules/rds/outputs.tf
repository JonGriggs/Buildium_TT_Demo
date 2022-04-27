output "rdsEndpoint" {
  value = aws_rds_cluster.auroraCluster[0].endpoint
}

