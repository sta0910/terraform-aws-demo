#-----------------
#Variables
#-----------------

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  type = string
}

variable "enviroment" {
  type = string
}

variable "domain" {
  type = string

}

#rdsの起動に時間がかかるため以下を追加
# terraform apply -var="create_rds=true"で指定しない場合はrdsは作成されない。
variable "create_rds" {
  default = false
}