# Terraform AWS practice

Udemy講座をベースにWeb３層アーキテクチャを作成。
気になったところは改修・追加予定。

VPC（public/private subnet構成）
ALB（L7ロードバランシング）
EC2（アプリケーション層）
RDS（private subnet配置）
S3 + CloudFront（静的コンテンツ配信）
Route53 + ACM（ドメイン・証明書管理）

## 使用技術
- Terraform
- AWS

## 学習目的
AWS Associate資格取得後の実践として、
IaCによるAWS環境構築を学習するために作成練習。

## 改修したもの
・RDSの起動に時間がかかるため、terraform apply時にオプションを付けないと起動できないようにロジックを追加。
