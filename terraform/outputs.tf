output "cluster_name" {
  value = module.eks.cluster_name
}

output "nodegroup_name" {
  value = module.nodegroup.nodegroup_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnet_ids
}

output "public_subnets" {
  value = module.vpc.public_subnet_ids
}
