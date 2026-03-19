#-----------------
# key pair
#-----------------

resource "aws_key_pair" "keypair" {
  key_name   = "${var.project}-${var.enviroment}-keypair"
  public_key = file("./src/tastylog-dev-keypair.pub")

  tags = {
    Name    = "${var.project}-${var.enviroment}-keypair"
    Project = var.project
    Env     = var.enviroment
  }
}

#-----------------
# SSM Parameter Store
#-----------------

resource "aws_ssm_parameter" "host" {
  count = var.create_rds ? 1 : 0

  name  = "/${var.project}/${var.enviroment}/app/MYSQL_HOST"
  type  = "String"
  value = aws_db_instance.mysql_standalone[0].address
}

resource "aws_ssm_parameter" "port" {
  count = var.create_rds ? 1 : 0
  name  = "/${var.project}/${var.enviroment}/app/MYSQL_PORT"
  type  = "String"
  value = aws_db_instance.mysql_standalone[0].port
}

resource "aws_ssm_parameter" "database" {
  count = var.create_rds ? 1 : 0

  name  = "/${var.project}/${var.enviroment}/app/MYSQL_DATABASE"
  type  = "String"
  value = aws_db_instance.mysql_standalone[0].name #nameがdatabase名
}

resource "aws_ssm_parameter" "username" {
  count = var.create_rds ? 1 : 0

  name  = "/${var.project}/${var.enviroment}/app/MYSQL_USERNAME"
  type  = "SecureString"
  value = aws_db_instance.mysql_standalone[0].username
}

resource "aws_ssm_parameter" "password" {
  count = var.create_rds ? 1 : 0

  name  = "/${var.project}/${var.enviroment}/app/MYSQL_PASSWORD"
  type  = "SecureString"
  value = aws_db_instance.mysql_standalone[0].password
}

#-----------------
# EC2 Instance
#-----------------

# resource "aws_instance" "app_server" {
#   ami                         = data.aws_ami.app.id #data.tfから参照
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.public_subnet_1a.id
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.app_ec2_profile.name
#   vpc_security_group_ids = [
#     aws_security_group.app_sg.id,
#     aws_security_group.opmng_sg.id
#   ]
#   key_name = aws_key_pair.keypair.key_name #.key_nameがキーペアの名前

#   tags = {
#     Name    = "${var.project}-${var.enviroment}-app-ec2"
#     Project = var.project
#     Env     = var.enviroment
#     Type    = "app"
#   }
# }

#-----------------
# lanuch template
#-----------------
resource "aws_launch_template" "app_lt" {
  update_default_version = true
  name                   = "${var.project}-${var.enviroment}-app-lt"

  image_id = data.aws_ami.app.id
  key_name = aws_key_pair.keypair.key_name

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name    = "${var.project}-${var.enviroment}-app-ec2"
      Project = var.project
      Env     = var.enviroment
      Type    = "app"
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      aws_security_group.app_sg.id,
      aws_security_group.opmng_sg.id
    ]
    delete_on_termination = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.app_ec2_profile.name
  }

  user_data = filebase64("./src/initialize.sh")
}

#-----------------
# ASG 
#-----------------

resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project}-${var.enviroment}-app-asg"
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  health_check_grace_period = 300
  health_check_type         = "ELB"

  vpc_zone_identifier = [
    aws_subnet.public_subnet_1a.id,
    aws_subnet.public_subnet_1c.id
  ]

  target_group_arns = [aws_alb_target_group.aws_alb_target_group.arn]

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
        version            = "LATEST"
      }
      override {
        instance_type = "t2.micro"
      }
    }
  }
}