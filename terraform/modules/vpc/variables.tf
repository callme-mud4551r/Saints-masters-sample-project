variable "vpc_name" {
  description = "VPC Name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of Public Subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of Private Subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}
