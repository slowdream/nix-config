# Overlays

Overlays для NixOS и Nix-Darwin.

Если вы мало знакомы с overlays, рекомендую сначала разобраться в том, что это и как их использовать,
через [Overlays - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/nixpkgs/overlays).

## Текущая структура

```
overlays/
├── README.md
├── default.nix          # Entrypoint for all overlays
└── fcitx5/              # Chinese input method configuration
    ├── README.md
    ├── default.nix      # fcitx5 overlay definition
    └── rime-data-flypy/ # Custom rime data for 小鹤音形输入法
        └── share/
            └── rime-data/
                ├── build/
                ├── default.custom.yaml
                ├── default.yaml
                ├── flypy.schema.yaml
                ├── flypy_full全码字.txt
                ├── flypy_sys.txt
                ├── flypy_top.txt
                ├── flypy_user.txt
                ├── lua/
                │   └── calculator_translator.lua
                ├── rime.lua
                ├── squirrel.custom.yaml
                └── squirrel.yaml
```

## Состав

### 1. `default.nix`

Точка входа overlays: выполняет и импортирует все overlay-файлы в текущей директории с заданными
аргументами.

### 2. `fcitx5`

Overlay для fcitx5: добавляет мою кастомизацию китайского метода ввода —
[小鹤音形输入法](https://flypy.com/).

Этот overlay включает:

- Custom rime data for 小鹤音形输入法 (Flypy input method)
- Cross-platform support for both Linux (fcitx5-rime) and macOS (squirrel)
- Pre-configured input method settings
