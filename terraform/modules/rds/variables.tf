variable "Three-tier-app" {
  type        = string
  description = "Project name for resources"
}

variable "vpc_id" {
  type        = string
  description = "The VPC where RDS will be deployed"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block of the VPC to allow access"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "private subnet IDs for the database subnet group"
}

variable "db_username" {
  type        = string
  description = "Master username for the MySQL database"
}

variable "db_password" {
  type        = string
  description = "Master password for the MySQL database"
  sensitive   = true
}


