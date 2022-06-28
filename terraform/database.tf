locals {
  name    = "slogging-postgres-db"
  db_name = "slogging"
}

resource "aws_security_group" "rds" {
  name   = local.name
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

resource "aws_db_parameter_group" "slogging_db" {
  name   = local.name
  family = "postgres14"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_subnet_group" "slogging_db" {
  name       = local.name
  subnet_ids = module.vpc.public_subnets

  tags = local.tags
}

resource "aws_db_instance" "slogging_db" {
  identifier        = local.name
  instance_class    = "db.t3.micro"
  allocated_storage = 5
  engine            = "postgres"
  engine_version    = "14.1"
  username          = var.db_username
  password          = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.slogging_db.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.slogging_db.name
  publicly_accessible    = true
  skip_final_snapshot    = true

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}
