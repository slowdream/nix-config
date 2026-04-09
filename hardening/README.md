# Linux Hardening

> В разработке (work in progress).

## Цель

- **Уровень системы**: защитить критичные файлы от доступа недоверенных приложений.
  1. Например cookies браузера, SSH keys и т.п.
- **Уровень приложения**: не давать недоверенным приложениям (например closed-source) возможности:
  1. Читать файлы, к которым у них не должно быть доступа.
     - Например вредоносное приложение не должно достучаться до cookies браузера, SSH keys и т.д.
  1. Ходить в сеть, если она им не нужна.
  1. Обращаться к hardware devices, которые им не нужны.

## Текущая структура

### 1. **Уровень системы**

- **AppArmor** (`apparmor/`): профили и конфигурация AppArmor
- **Kernel & system hardening** (`profiles/`): системные hardened profiles

### 2. **Уровень приложения**

- **Nixpak** (`nixpaks/`): sandboxing на базе Bubblewrap
  - Конфигурация Firefox
  - Конфигурация QQ (китайский мессенджер)
  - Модульная система с переиспользуемыми компонентами
- **Firejail** (legacy): sandboxing на SUID (не используется)
- **Bubblewrap** (`bwraps/`): прямые конфигурации bubblewrap
  - Sandboxing для WeChat

## Статус реализации

| Компонент          | Статус    | Примечание                                 |
| ------------------ | --------- | ------------------------------------------ |
| AppArmor Profiles  | 🚧 WIP    | Базовая структура есть                     |
| Nixpak Firefox     | ✅ Active | Firefox через nixpak                       |
| Nixpak QQ          | ✅ Active | QQ в sandbox                               |
| Bubblewrap WeChat  | ✅ Active | Отдельный sandbox для WeChat               |
| System Profiles    | 🚧 WIP    | Профили hardened system                    |

## Структура каталогов

```
hardening/
├── README.md
├── apparmor/           # AppArmor security profiles
│   └── default.nix
├── bwraps/            # Direct bubblewrap configurations
│   ├── default.nix
│   └── wechat.nix
├── nixpaks/           # Nixpak application sandboxing
│   ├── default.nix
│   ├── firefox.nix
│   ├── qq.nix
│   └── modules/       # Reusable nixpak modules
│       ├── gui-base.nix
│       └── network.nix
└── profiles/          # System hardening profiles
    └── default.nix
```

## Kernel hardening

- NixOS kernel config:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/linux/kernel/hardened/config.nix

## System hardening

- NixOS profile:
  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/profiles/hardened.nix
- AppArmor: [roddhjav/apparmor.d](https://github.com/roddhjav/apparmor.d)
  - https://gitlab.com/apparmor/apparmor/-/wikis/Documentation
  - AppArmor.d — это более 1500 профилей AppArmor, цель которых — ограничить большинство Linux-приложений и процессов.
  - Но все профили AppArmor исходят из FHS filesystem, из‑за чего политики AppArmor на NixOS фактически не срабатывают.
  - AppArmor on NixOS roadmap:
    - https://discourse.nixos.org/t/apparmor-on-nixos-roadmap/57217
    - https://github.com/LordGrimmauld/aa-alias-manager
- SELinux: слишком сложен, для personal use не рекомендуется.

## Application sandboxing

- [Bubblewrap](https://github.com/containers/bubblewrap):
  [nixpak](https://github.com/nixpak/nixpak) — безопаснее, чем Firejail, но без «батареек из коробки».
  - FHSEnv в NixOS по умолчанию реализован на Bubblewrap.
- [Firejail](https://github.com/netblue30/firejail/tree/master/etc): SUID security sandbox с сотнями профилей для распространённых приложений в default installation.
  - https://wiki.nixos.org/wiki/Firejail
  - Firejail требует SUID, что считается security risk —
    [Does firejail improve the security of my system?](https://github.com/netblue30/firejail/discussions/4601)
- [Systemd/Hardening](https://wiki.nixos.org/wiki/Systemd/Hardening): у systemd тоже есть sandboxing features.

## Примечание

**Запуск недоверенного кода никогда не бывает безопасным; kernel hardening и sandboxing это не меняют**.

Если нужно выполнять недоверенный код, используйте VM и изолированную сеть — это даёт гораздо более высокий уровень безопасности.

## Ссылки

- [Harden your NixOS workstation - dataswamp](https://dataswamp.org/~solene/2022-01-13-nixos-hardened.html)
- [Linux Insecurities - Madaidans](https://madaidans-insecurities.github.io/linux.html)
- [Sandboxing all programs by default - NixOS Discourse](https://discourse.nixos.org/t/sandboxing-all-programs-by-default/7792)
- [Paranoid NixOS Setup - xeiaso](https://xeiaso.net/blog/paranoid-nixos-2021-07-18/)
- [nix-mineral](https://github.com/cynicsketch/nix-mineral): NixOS module для удобного system hardening.
- Конфиги AppArmor:
  - https://github.com/zramctl/dotfiles/blob/4fe177f6984154960942bb47d5a375098ec6ed6a/modules/nixos/security/apparmor.nix#L4
  - https://git.grimmauld.de/Grimmauld/grimm-nixos-laptop/src/branch/main/hardening
- Прочее:
  - Напрямую через `buildFHSUserEnvBubblewrap`:
