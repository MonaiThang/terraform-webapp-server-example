# database
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.app_prefix}-db-subnet-group"
  subnet_ids = [for s in aws_subnet.subnet_private : s.id]

  tags = {
    "Name" = "${var.app_prefix}-db-subnet-group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "${var.app_prefix}-db-sg"
  description = "Allow PostgreSQL database inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "PostgreSQL port from webapp"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [for s in aws_instance.webapp[*] : "${s.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.app_prefix}-db-sg"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_"
}

resource "aws_db_instance" "db" {
  depends_on = [aws_db_subnet_group.db_subnet_group]

  identifier     = "${var.app_prefix}-db"
  instance_class = var.db_type

  allocated_storage = var.db_storage
  storage_type      = "gp2"
  storage_encrypted = true

  engine               = "postgres"
  engine_version       = "14.2"
  parameter_group_name = "default.postgres14"

  db_name  = "webapp"
  username = "webapp"
  password = random_password.password.result

  port = 5432

  vpc_security_group_ids = [aws_security_group.db_security_group.id]

  copy_tags_to_snapshot = true
  deletion_protection   = true

  tags = {
    "cost-centre" = var.app_prefix
    "Name"        = "${var.app_prefix}-db"
  }

  db_subnet_group_name = "${var.app_prefix}-db-subnet-group"
}

# secrets
resource "aws_secretsmanager_secret" "db_connection" {
  name = "${var.app_prefix}/db_con"

  tags = {
    "cost-centre" = var.app_prefix
  }
}

locals {
  db_connection = {
    username             = aws_db_instance.db.username
    engine               = "postgres"
    dbname               = aws_db_instance.db.name
    host                 = aws_db_instance.db.address
    password             = random_password.password.result
    port                 = aws_db_instance.db.port
    dbInstanceIdentifier = aws_db_instance.db.identifier
    convertUnicode       = "True"
  }
  type = "map"
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.db_connection.id
  secret_string = jsonencode(local.db_connection)
}
