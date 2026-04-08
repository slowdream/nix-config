# Terraform's S3 Backend

Этот terraform workspace используется только один раз, и мы не сохраняем файл `terraform.tfstate`.

Он нужен, чтобы создать bucket в MinIO для хранения всех остальных `tfstate` файлов.
