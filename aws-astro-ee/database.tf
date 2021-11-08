resource aws_db_subnet_group db {
  name       = var.cluster_name
  subnet_ids = data.aws_subnet_ids.eks.ids
}

resource random_password db {
  length = 20
  special = false # was having issues with the url
  number = false  # was having issues with the url
  upper = true
  lower = true
}

resource aws_security_group db_rds {
  name   = var.cluster_name
  vpc_id = data.aws_vpc.eks.id

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
}

resource aws_db_instance db {
  identifier             = var.cluster_name
  instance_class         = var.database_instance_size
  allocated_storage      = var.postgres_storage_gb
  engine                 = "postgres"
  engine_version         = var.postgres_version
  username               = "postgres"
  password               = random_password.db.result
  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db_rds.id]
  parameter_group_name   = "default.postgres13"
  publicly_accessible    = true
  skip_final_snapshot    = true
}
