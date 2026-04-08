<h2 align="center">:snowflake: Ryan4Yin's Nix Config :snowflake:</h2>

<p align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" />
</p>

<p align="center">
	<a href="https://github.com/ryan4yin/nix-config/stargazers">
		<img alt="Stargazers" src="https://img.shields.io/github/stars/ryan4yin/nix-config?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://nixos.org/">
        <img src="https://img.shields.io/badge/NixOS-25.11-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
    <a href="https://github.com/ryan4yin/nixos-and-flakes-book">
        <img src="https://img.shields.io/badge/Nix%20Flakes-learning-informational.svg?style=for-the-badge&logo=nixos&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"></a>
  </a>
</p>

> Моя конфигурация становится всё сложнее, и **новичкам будет трудно её читать**. Если вы только
> начинаете с NixOS и хотите понять, как я его использую, рекомендую сначала посмотреть
> [ryan4yin/nix-config/releases](https://github.com/ryan4yin/nix-config/releases) и **переключиться на
> более простые старые версии — например,
> [i3-kickstarter](https://github.com/ryan4yin/nix-config/tree/i3-kickstarter). Их будет гораздо
> легче понять**.

Этот репозиторий содержит Nix-код для сборки моих систем:

1. NixOS Desktops: NixOS с home-manager, niri, agenix и т.д.
2. NixOS Servers: виртуальные машины (Proxmox/KubeVirt) и сервисы (kubernetes, homepage, prometheus, grafana и т.д.).

Подробности по каждому хосту см. в [./hosts](./hosts).

Как создавать и управлять Virtual Machine в KubeVirt из этого flake — см. [./Virtual-Machine.md](./Virtual-Machine.md).

## Зачем NixOS и Flakes?

Nix позволяет делать управляемые, совместные и воспроизводимые деплои. Это значит, что один раз
настроив систему, вы получаете конфигурацию, которая работает (почти) всегда. Если кто-то делится
своей конфигурацией, другой человек может просто использовать её (если действительно понимает, что
копирует/на что ссылается).

Про Flakes см.
[Introduction to Flakes - NixOS & Nix Flakes Book](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/introduction-to-flakes)

**Хотите разобраться в NixOS и Flakes глубже? Нужен дружелюбный для новичков туториал и best
practices? Вам не обязательно повторять мой путь с болью — загляните в
[NixOS & Nix Flakes Book - 🛠️ ❤️ An unofficial & opinionated :book: for beginners](https://github.com/ryan4yin/nixos-and-flakes-book)!**

## Компоненты

|                                                                | NixOS(Wayland)                                                                                                      |
| -------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Window Manager**                                             | [Niri][Niri]                                                                                                        |
| **Terminal Emulator**                                          | [Zellij][Zellij] + [foot][foot]/[Kitty][Kitty]/[Alacritty][Alacritty]/[Ghostty][Ghostty]                            |
| **Status Bar** / **Notifier** / **Launcher** / **lockscreens** | [noctalia-shell][noctalia-shell]                                                                                    |
| **Display Manager**                                            | [tuigreet][tuigreet]                                                                                                |
| **Color Scheme**                                               | [catppuccin-nix][catppuccin-nix]                                                                                    |
| **network management tool**                                    | [NetworkManager][NetworkManager]                                                                                    |
| **Input method framework**                                     | [Fcitx5][Fcitx5] + [rime][rime] + [小鹤音形 flypy][flypy]                                                           |
| **System resource monitor**                                    | [Btop][Btop]                                                                                                        |
| **File Manager**                                               | [Yazi][Yazi] + [thunar][thunar]                                                                                     |
| **Shell**                                                      | [Nushell][Nushell] + [Starship][Starship]                                                                           |
| **Media Player**                                               | [mpv][mpv]                                                                                                          |
| **Text Editor**                                                | [Neovim][Neovim]                                                                                                    |
| **Fonts**                                                      | [Nerd fonts][Nerd fonts]                                                                                            |
| **Image Viewer**                                               | [imv][imv]                                                                                                          |
| **Screenshot Software**                                        | Niri's builtin function                                                                                             |
| **Screen Recording**                                           | [OBS][OBS]                                                                                                          |
| **Filesystem & Encryption**                                    | tmpfs as `/`, [Btrfs][Btrfs] subvolumes on a [LUKS][LUKS] encrypted partition for persistent, unlock via passphrase |
| **Secure Boot**                                                | [lanzaboote][lanzaboote]                                                                                            |

Wallpapers: `https://github.com/ryan4yin/wallpapers`

## Скриншоты

![desktop](./_img/2026-01-05_niri-noctalia_desktop.webp)

![overview](./_img/2026-01-04_niri-noctalia_overview.webp)

![nvim](./_img/2026-01-04_niri-noctalia_nvim.webp)

## Neovim

Подробности см. в [./home/base/tui/editors/neovim/](./home/base/tui/editors/neovim/).

## Управление секретами

Подробности см. в [./secrets](./secrets).

## Agents

См. [./agents](./agents) — переиспользуемые agent-файлы и скрипт установки.

## Как деплоить этот flake?

<!-- prettier-ignore -->
> :red_circle: **ВАЖНО**: **не деплойте этот flake напрямую на свою машину :exclamation: — это не
> получится.** Здесь есть мои hardware-конфигурации (например,
> [hardware-configuration.nix](hosts/idols-ai/hardware-configuration.nix),
> [Nvidia Support](https://github.com/ryan4yin/nix-config/blob/v0.1.1/hosts/idols-ai/default.nix#L77-L91)
> и т.д.), которые не подходят вашему железу, а также для деплоя требуется мой приватный репозиторий
> секретов. Используйте этот репозиторий как референс для своей конфигурации.

Для NixOS:

> To deploy this flake from NixOS's official ISO image (purest installation method), please refer to
> [./nixos-installer/](./nixos-installer/)

```bash
# deploy one of the configuration based on the hostname
sudo nixos-rebuild switch --flake .#ai-niri

# Deploy the niri nixosConfiguration by hostname match
just niri

# or we can deploy with details
just niri debug
```

> [What y'all will need when Nix drives you to drink.](https://www.youtube.com/watch?v=Eni9PPPPBpg)
> (copy from hlissner's dotfiles, it really matches my feelings when I first started using NixOS...)

## Ссылки

Другие dotfiles, которые меня вдохновили:

- Nix Flakes
  - [NixOS-CN/NixOS-CN-telegram](https://github.com/NixOS-CN/NixOS-CN-telegram)
  - [notusknot/dotfiles-nix](https://github.com/notusknot/dotfiles-nix)
  - [xddxdd/nixos-config](https://github.com/xddxdd/nixos-config)
  - [bobbbay/dotfiles](https://github.com/bobbbay/dotfiles)
  - [gytis-ivaskevicius/nixfiles](https://github.com/gytis-ivaskevicius/nixfiles)
  - [davidtwco/veritas](https://github.com/davidtwco/veritas)
  - [gvolpe/nix-config](https://github.com/gvolpe/nix-config)
  - [Ruixi-rebirth/flakes](https://github.com/Ruixi-rebirth/flakes)
  - [fufexan/dotfiles](https://github.com/fufexan/dotfiles): gtk theme, xdg, git, media, etc.
  - [nix-community/srvos](https://github.com/nix-community/srvos): a collection of opinionated and
    sharable NixOS configurations for servers
- Modularized NixOS Configuration
  - [hlissner/dotfiles](https://github.com/hlissner/dotfiles)
  - [viperML/dotfiles](https://github.com/viperML/dotfiles)
- Neovim/AstroNvim
  - [maxbrunet/dotfiles](https://github.com/maxbrunet/dotfiles): astronvim with nix flakes.
- Misc
  - [1amSimp1e/dots](https://github.com/1amSimp1e/dots)

[Niri]: https://github.com/YaLTeR/niri
[Kitty]: https://github.com/kovidgoyal/kitty
[foot]: https://codeberg.org/dnkl/foot
[Alacritty]: https://github.com/alacritty/alacritty
[Ghostty]: https://github.com/ghostty-org/ghostty
[Nushell]: https://github.com/nushell/nushell
[Starship]: https://github.com/starship/starship
[Fcitx5]: https://github.com/fcitx/fcitx5
[rime]: https://wiki.archlinux.org/title/Rime
[flypy]: https://flypy.cc/
[Btop]: https://github.com/aristocratos/btop
[mpv]: https://github.com/mpv-player/mpv
[Zellij]: https://github.com/zellij-org/zellij
[Neovim]: https://github.com/neovim/neovim
[AstroNvim]: https://github.com/AstroNvim/AstroNvim
[imv]: https://sr.ht/~exec64/imv/
[OBS]: https://obsproject.com
[Nerd fonts]: https://github.com/ryanoasis/nerd-fonts
[catppuccin-nix]: https://github.com/catppuccin/nix
[NetworkManager]: https://wiki.gnome.org/Projects/NetworkManager
[wl-clipboard]: https://github.com/bugaevc/wl-clipboard
[tuigreet]: https://github.com/apognu/tuigreet
[thunar]: https://gitlab.xfce.org/xfce/thunar
[Yazi]: https://github.com/sxyazi/yazi
[Catppuccin]: https://github.com/catppuccin/catppuccin
[Btrfs]: https://btrfs.readthedocs.io
[LUKS]: https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system
[lanzaboote]: https://github.com/nix-community/lanzaboote
[noctalia-shell]: https://github.com/noctalia-dev/noctalia-shell
