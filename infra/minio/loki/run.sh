# для provider
#
# export MINIO_PASSWORD="xxx"

# для S3 backend в terraform
#
# export AWS_ACCESS_KEY_ID="xxx"
# export AWS_SECRET_ACCESS_KEY="xxx"
#
terraform init
terraform plan
terraform apply

# показать secret key
terraform output loki_secretkey
