# Host Home Modules

Эта директория содержит host-specific entry modules для Home Manager.

## Layout

- `home/hosts/linux/*.nix`: Linux host home modules

## Соглашения

1. Каждый host output должен ссылаться только на один файл внутри `home/hosts/...`.
2. Импорт shared home modules должен делаться внутри host-файла.
   - Linux hosts обычно импортируют `../../linux/core.nix` или `../../linux/gui.nix`.
3. Host-specific overrides (SSH keys, desktop toggles, host-local config links) живут в этом же
   host-файле.
