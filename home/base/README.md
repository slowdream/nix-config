# Базовые подмодули Home Manager

Эта директория содержит cross-platform базовые конфигурации, которые разделяются между системами
Linux и Darwin.

## Структура конфигурации

### Core System

- **core/**: базовые cross-platform конфигурации
  - **core.nix**: минимальная конфигурация home-manager
  - **shells/**: конфигурации shell (bash, zsh, fish, nu)
  - **editors/**: конфигурации текстовых редакторов
    - **neovim/**: Neovim с кастомными plugins и настройками
    - **helix/**: конфигурация Helix
  - **btop.nix**: инструменты мониторинга системы
  - **git.nix**: конфигурация Git и aliases
  - **npm.nix**: управление Node.js пакетами
  - **pip.nix**: управление Python пакетами
  - **starship.nix**: cross-shell prompt конфигурация
  - **theme.nix**: color schemes и theming
  - **yazi.nix**: конфигурация terminal file manager
  - **zellij/**: terminal multiplexer с кастомными layouts

### Desktop Environment

- **gui/**: cross-platform GUI приложения и конфигурации
  - **dev-tools.nix**: dev tools и IDE
  - **media.nix**: media players и utilities
  - **terminal/**: конфигурации terminal emulators
    - **alacritty/**: Alacritty
    - **kitty/**: Kitty
    - **foot/**: Foot (Linux)
    - **ghostty/**: Ghostty

### Terminal / TUI

- **tui/**: terminal/TUI конфигурации
  - **cloud/**: cloud development tools (Terraform и т.д.)
  - **container.nix**: container tools (Docker, Podman)
  - **dev-tools.nix**: terminal-based dev tools
  - **editors/**: конфигурации редакторов в терминале
  - **encryption/**: encryption и security tools
  - **gpg/**: управление GPG keys
  - **password-store/**: управление паролями через pass
  - **shell.nix**: конфигурация shell окружения
  - **ssh/**: SSH конфигурация и управление
  - **zellij/**: terminal workspace управление

### System Management

- **home.nix**: Main home manager configuration file

## Совместимость платформ

Все конфигурации в этой директории рассчитаны на работу в:

- **Linux**: All distributions with Nix and Home Manager
- **WSL**: Windows Subsystem for Linux

## Использование

Эти базовые конфигурации — фундамент для Linux Darwin систем: они дают единообразное окружение на
разных платформах и при этом позволяют делать platform-specific кастомизации.
