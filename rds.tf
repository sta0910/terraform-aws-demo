#-----------------
# rds parameter group
#-----------------

resource "aws_db_parameter_group" "mysql_standalone_parameter_group" {
  name   = "${var.project}-${var.enviroment}-mysql-standalone-parametergroup"
  family = "mysql8.0"

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

#-----------------
# rds option group
#-----------------

resource "aws_db_option_group" "mysql_standalone_optiongroup" {
  name                 = "${var.project}-${var.enviroment}-mysql-standalone-optiongroup"
  engine_name          = "mysql"
  major_engine_version = "8.0"
}

#-----------------
# rds subnet group
#-----------------

resource "aws_db_subnet_group" "mysql_standalone_subnetgroup" {
  name = "${var.project}-${var.enviroment}-mysql-standalone-subnetgroup"
  subnet_ids = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1c.id
  ]

  tags = {
    Name    = "${var.project}-${var.enviroment}-mysql-standalone-subnetgroup"
    Project = var.project
    Env     = var.enviroment
  }
}

#-----------------
# rds instance
#-----------------

resource "random_string" "db_passward" {
  length  = 16
  special = false
}

resource "aws_db_instance" "mysql_standalone" {
  count          = var.create_rds ? 1 : 0 #rdsをapply時に指定しないと起動しない
  engine         = "mysql"                #DBエンジン
  engine_version = "8.0.40"

  identifier = "${var.project}-${var.enviroment}-mysql-standalone" #DBインスタンス名

  username = "admin"
  password = random_string.db_passward.result

  instance_class = "db.t3.micro"

  allocated_storage     = 20 #20GBでスタート
  max_allocated_storage = 50 #最大50GBまで
  storage_type          = "gp2"
  storage_encrypted     = false #暗号化

  multi_az               = false
  availability_zone      = "ap-northeast-1a"
  db_subnet_group_name   = aws_db_subnet_group.mysql_standalone_subnetgroup.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  port                   = 3306

  name                 = "tastylog" #DB名
  parameter_group_name = aws_db_parameter_group.mysql_standalone_parameter_group.name
  option_group_name    = aws_db_option_group.mysql_standalone_optiongroup.name

  backup_window              = "04:00-05:00"         #バックアップを行う時間
  backup_retention_period    = 7                     #バックアップ保持期間
  maintenance_window         = "Mon:05:00-Mon:08:00" #メンテナンスを行う時間（バックアップを先に行うように）
  auto_minor_version_upgrade = false

  deletion_protection = false
  skip_final_snapshot = true

  apply_immediately = true #初回作成時にすぐ作成できる

  tags = {
    Name    = "${var.project}-${var.enviroment}-mysql-standalone"
    Project = var.project
    Env     = var.enviroment
  }
}