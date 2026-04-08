# Конфигурации desktop environment

Эта директория содержит конфигурации desktop environment и window manager, которыми управляет Home
Manager.

## Доступные конфигурации

### Window Managers

- **niri**: конфигурация Niri compositor с кастомными настройками, keybindings, правилами
  spawn-at-startup и window rules

### Базовое desktop environment

- **base**: общие desktop конфигурации, разделяемые между всеми окружениями, включая:
  - **Noctalia Shell**: all-in-one Wayland desktop shell (заменяет gammastep, swaylock, anyrun, mako,
    waybar, wallpaper-switcher, wlogout и другие desktop tools)
  - creative tools и media applications
  - development tools
  - Fcitx5 input method framework
  - games и gaming utilities
  - GTK theme configurations
  - immutable file handling
  - note-taking applications
  - Wayland applications
  - XDG desktop configurations

### Editor Configurations

- **editors**: конфигурации text editor и интеграции

## Почему Desktop Environments лучше ставить через Home Manager, а не через NixOS Module?

1. **Configuration Location**: конфигурационные файлы desktop environment находятся в `~/.config`,
   поэтому ими удобно управлять через Home Manager.

2. **User-specific Services**: user-specific systemd services (noctalia-shell, fcitx5, hypridle и
   т.д.) легко управляются через Home Manager. Если бы desktop environments настраивались через NixOS
   Module, эти user-level services могли бы не стартовать автоматически. С Home Manager modules
   проще контролировать порядок зависимостей systemd services.

3. **System Benefits**: By minimizing package installation through NixOS Module:
3. **System Benefits**: при уменьшении установки пакетов через NixOS Module:
   - Делает NixOS систему более безопасной и стабильной
   - Повышает переносимость на не-NixOS системы, т.к. Home Manager можно поставить на любой Linux
     system
   - Упрощает переключение между разными window managers без system-level изменений
