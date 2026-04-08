# Infrastructure as Code

Эта директория содержит конфигурации Infrastructure as Code (IaC) на Terraform — в основном для
управления storage и backend-сервисами.

## Текущая структура

```
infra/
├── README.md
└── minio/                    # MinIO S3-compatible storage configurations
    ├── loki/                 # Loki log storage buckets
    │   ├── README.md
    │   ├── loki.tf          # Loki-specific bucket configuration
    │   ├── main.tf          # Main Terraform configuration
    │   └── run.sh           # Deployment script
    └── tf-s3-backend/        # Terraform S3 backend setup
        ├── README.md
        ├── main.tf          # Main configuration
        ├── run.sh           # Deployment script
        └── tf-s3-backend.tf # Backend bucket configuration
```

## Обзор сервисов

### MinIO Storage

- **Loki Buckets**: отдельное хранилище для Grafana Loki (log aggregation)
- **Terraform Backend**: централизованное хранение state для всех Terraform configurations

### Внешние ресурсы

- **Kubernetes YAML**: управляется в отдельном репозитории
  [ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops)
- **Secrets Management**: через agenix в [../secrets](../secrets/)

## Использование

Каждая поддиректория содержит свою Terraform-конфигурацию:

1. **Перейти к нужному сервису**:

   ```bash
   cd infra/minio/loki
   ```

2. **Задеплоить конфигурацию**:

   ```bash
   ./run.sh
   ```

3. **Ручной деплой**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Безопасность

- Все storage buckets настроены с корректными access policies
- State files шифруются at rest
- Access credentials берутся из environment variables
- Network access ограничен только необходимыми hosts
