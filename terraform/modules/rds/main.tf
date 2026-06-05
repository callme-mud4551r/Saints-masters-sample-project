#------Subnet Group to use----------
resource "aws_db_subnet_group" "main" {
  name       = "${var.Three-tier-app}-subnet-db-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.Three-tier-app}-db-subnet-group"
  }
}

#--------create rds security group--------
resource "aws_security_group" "db" {
  name        = "${var.Three-tier-app}-db-sg"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  #----inbound-----
  ingress {
    description = "Mysql access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  #----outbound----
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "${var.Three-tier-app}-db-sg"
  }
}

#-----------------MYSQL Instance-------------------
resource "aws_db_instance" "mysql" {

  identifier             = "${var.Three-tier-app}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 100
  db_name                = "three_tier_app_db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = true

}

