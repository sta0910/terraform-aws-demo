概要

Udemy講座をベースに、AWS上でWeb3層アーキテクチャを構築。
IaC（Terraform）による再現性のあるインフラ構築を実践し、課題点については随時改善・機能追加を実施。

使用技術
Terraform
AWS
構成（Web3層アーキテクチャ）
VPC：public / private subnet構成
ALB：L7ロードバランシング
EC2：アプリケーション層
RDS：private subnetに配置（DB層）
S3 + CloudFront：静的コンテンツ配信
Route53 + ACM：ドメイン管理・SSL証明書
学習目的

AWS Associate資格で得た知識をもとに、
Terraformを用いたAWSインフラ構築の実践力を習得することを目的として作成。

## 改修したもの
・RDSの起動に時間がかかるため、terraform apply時にオプションを付けないと起動できないようにロジックを追加。
