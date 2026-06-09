output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "the vpc id "
}

output "rds_endpoint" {
  value       = module.rds.db_endpoint
  description = "The rds endpoint url"
}

output "cluster_name" {

  value = module.eks.cluster_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
