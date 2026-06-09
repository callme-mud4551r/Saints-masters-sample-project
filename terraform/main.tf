#-----------VPC Module----------
module "vpc" {
  source         = "./modules/vpc"
  Three-tier-app = var.Three-tier-app
}


#----------RDS module--------------
module "rds" {
  source             = "./modules/rds"
  Three-tier-app     = var.Three-tier-app
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  private_subnet_ids = module.vpc.private_subnet_ids
  db_username        = var.db_username
  db_password        = var.db_password
}


#----------EKS module------------------
module "eks" {
  source             = "./modules/eks"
  Three-tier-app     = var.Three-tier-app
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

}


#-------------ECR module----------------------
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "three-tier-app"
}
