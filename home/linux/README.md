# Подмодули Home Manager для Linux

Эта директория содержит Linux-specific конфигурации Home Manager, организованные под разные use
cases.

## Конфигурационные модули

### Core Configurations

- **core.nix**: базовые Linux-specific настройки и конфигурации
- **base/**: базовые Linux-конфигурации (shell, tools, utilities)
  - `shell.nix`: конфигурации shell и aliases
  - `tools.nix`: базовые command-line tools и utilities

### Desktop Configurations

- **gui/**: конфигурации desktop environment
  - **niri/**: конфигурация Niri compositor
  - **base/**: общие desktop приложения и сервисы
  - **editors/**: конфигурации text editor для desktop environment

### Доступные entry points

- **core.nix**: core Linux конфигурация, подходит для базовых setup
- **tui.nix**: terminal/TUI конфигурация для лёгких окружений
- **gui.nix**: entry point для GUI, импортирует desktop environments

## Использование

- **Lightweight/Terminal**: используйте `core.nix` или `tui.nix` для terminal-focused setups
- **Desktops**: используйте `gui.nix` для полного desktop environment с Noctalia Shell и Niri compositor
- **Custom**: комбинируйте конфигурации под свой use case
