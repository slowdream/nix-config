# Variables

Общие переменные и конфигурация, используемые в NixOS.

## Текущая структура

```
vars/
├── README.md
├── default.nix         # Main variables entry point
└── networking.nix      # Network configuration and host definitions
```

## Состав

### 1. `default.nix`

Содержит информацию о пользователе, SSH-ключи и настройки пароля:

- Данные пользователя (username, full name, email)
- Начальный hashed password для новых установок
- SSH authorized keys (основной и резервный наборы)
- Ссылки на public keys для доступа к системе

### 2. `networking.nix`

Полная network-конфигурация, включающая:

- **Gateway settings**: конфигурация main router и proxy gateway
- **DNS servers**: IPv4 и IPv6 name servers
- **Host inventory**: полная карта всех hosts с их network interfaces и IP addresses
- **SSH configuration**: remote builder aliases и known hosts конфигурация
- **Network topology**: physical machines, VMs, Kubernetes clusters и SBCs

## Категории хостов

Network-конфигурация покрывает:

- **Physical machines**: Desktop PCs, SBCs
- **Virtual machines**: KubeVirt guests, K3s nodes
- **Kubernetes clusters**: production и testing environments
- **Network infrastructure**: routers, gateways и DNS конфигурация

## Использование

Эти переменные импортируются и используются по всей конфигурации, чтобы обеспечить единообразие для
всех хостов и держать network/security настройки централизованными.
