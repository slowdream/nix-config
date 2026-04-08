# Подмодули Home Manager

Эта директория содержит конфигурации Home Manager, организованные по платформам и назначению.

## Текущая структура

```
home/
├── base/              # Cross-platform home manager configurations
│   ├── core/          # Essential applications and settings
│   │   ├── editors/   # Editor configurations (Neovim, Helix)
│   │   ├── shells/    # Shell configurations (Nushell, Zellij)
│   │   └── ...
│   ├── gui/           # GUI applications and desktop settings
│   │   ├── terminal/  # Terminal emulators (Kitty, Alacritty, etc.)
│   │   └── ...
│   ├── tui/           # Terminal/TUI applications
│   │   ├── editors/   # TUI editors and related tools
│   │   ├── encryption/ # GPG, password-store, etc.
│   │   └── ...
│   └── home.nix       # Main home manager entry point
├── linux/             # Linux-specific home manager configurations
│   ├── base/          # Linux base configurations
│   ├── gui/           # Linux GUI applications
│   │   ├── niri/      # Niri window manager
│   │   └── ...
│   ├── editors/       # Linux-specific editors
│   └── ...
└── hosts/             # Host-specific home manager entry modules
    └── linux/         # Linux host home modules (ai, k3s-*, etc.)
```

## Обзор модулей

1. **base**: базовый модуль, подходящий для Linux
   - Cross-platform приложения и настройки
   - Общие конфигурации для editors, shells и необходимых инструментов

2. **linux**: Linux-specific конфигурация
   - Desktop environments (Noctalia Shell, Niri compositor)
   - Linux-specific GUI приложения
   - инструменты system integration

4. **hosts**: host entry modules для Home Manager
   - Каждый output должен ссылаться только на один host home module file
   - Host modules отвечают за импорт общих стеков (`home/linux/*`) и
     применение host overrides
