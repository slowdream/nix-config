# Library

Эта директория содержит вспомогательные функции, которые используются в `flake.nix`, чтобы уменьшить
дублирование кода и упростить добавление новых машин.

## Текущие функции

### Генераторы базовых систем

1. **`attrs.nix`** - утилиты для работы с attribute set
2. **`macosSystem.nix`** - генератор конфигурации macOS для
   [nix-darwin](https://github.com/LnL7/nix-darwin)
3. **`nixosSystem.nix`** - генератор конфигурации NixOS
4. **`colmenaSystem.nix`** - конфигурация remote deployment для
   [colmena](https://github.com/zhaofengli/colmena)

### Специализированные генераторы модулей

5. **`genK3sAgentModule.nix`** - генератор конфигурации для K3s agent node
6. **`genK3sServerModule.nix`** - генератор конфигурации для K3s server node
7. **`genKubeVirtGuestModule.nix`** - генератор конфигурации KubeVirt guest VM
8. **`genKubeVirtHostModule.nix`** - генератор конфигурации KubeVirt host

### Точка входа

9. **`default.nix`** - основная точка входа: импортирует все функции и экспортирует их как единый
   attribute set

## Назначение

Эти функции нужны, чтобы:

- Генерировать единообразные конфигурации для разных архитектур
- Давать type-safe конфигурацию для сложных систем
- Упрощать масштабирование инфраструктуры
- Поддерживать и локальную разработку, и production deployments

## Поддерживаемые архитектуры

- **x86_64-linux**: основные desktop systems
- **aarch64-linux**: ARM64 Linux systems (Apple Silicon, SBCs)
- **aarch64-darwin**: Apple Silicon macOS systems
