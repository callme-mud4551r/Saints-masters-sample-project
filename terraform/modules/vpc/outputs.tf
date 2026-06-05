output "vpc_id" {

  value       = aws_vpc.main.id
  description = "The ID of the vpc"
}

output "vpc_cidr_block" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR of vpc"

}

output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = " 2 Private subnet ID's"
}

output "public_subnet_ids" {

  value       = aws_subnet.public[*].id
  description = "2 public subnet ID's"

}

