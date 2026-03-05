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
# EC2 Instance
#-----------------

resource "aws_instance" "app_server" {
  ami                         = data.aws_ami.app.id #data.tfから参照
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.app_sg.id,
    aws_security_group.opmng_sg.id
  ]
  key_name = aws_key_pair.keypair.key_name #.key_nameがキーペアの名前

  tags = {
    Name    = "${var.project}-${var.enviroment}-app-ec2"
    Project = var.project
    Env     = var.enviroment
    Type    = "app"
  }
}