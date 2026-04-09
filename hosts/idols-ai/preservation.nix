{
  preservation,
  lib,
  pkgs,
  myvars,
  ...
}:
let
  inherit (myvars) username;
in
{
  imports = [
    preservation.nixosModules.default
  ];

  preservation.enable = true;
  # preservation: нужен initrd с systemd
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    # `sudo ncdu -x /`
    pkgs.ncdu
  ];

  # Два способа чистить root при каждой загрузке:
  ##  1. tmpfs на /
  ##  2. (только btrfs/zfs) пустой snapshot root и откат при загрузке:
  ##     boot.initrd.postDeviceCommands = ''
  ##       mkdir -p /run/mymount
  ##       mount -o subvol=/ /dev/disk/by-uuid/UUID /run/mymount
  ##       btrfs subvolume delete /run/mymount
  ##       btrfs subvolume snapshot / /run/mymount
  ##     '';
  #
  #  См. https://grahamc.com/blog/erase-your-darlings/

  # NOTE: preservation монтирует в /persistent только список ниже
  # Если путь уже в rootfs — сначала перенесите в /persistent
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote / secure boot
      # секреты
      "/etc/agenix/"

      "/var/log"

      # кэш davfs2 — иначе много RAM
      "/var/cache/davfs2"

      # ядро системы
      "/var/lib/nixos"
      "/var/lib/systemd"
      {
        directory = "/var/lib/private";
        mode = "0700";
      }

      # контейнеры
      # "/var/lib/docker"
      "/var/lib/cni"
      "/var/lib/containers"

      # прочие данные
      "/var/lib/flatpak"

      # виртуализация
      "/var/lib/libvirt"
      "/var/lib/lxc"
      "/var/lib/lxd"
      "/var/lib/qemu"
      # "/var/lib/waydroid"

      # сеть
      "/var/lib/bluetooth"
      "/var/lib/NetworkManager"
      "/var/lib/iwd"
      "/var/lib/tailscale"
      "/var/lib/netbird-homelab" # клиент netbird homelab
      "/etc/netbird-homelab"
    ];
    files = [
      # machine-id
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
    ];

    # каталоги → /persistent/home/$USER
    users.${username} = {
      commonMountOptions = [
        "x-gvfs-hide"
      ];
      directories = [
        # ======================================
        # Каталоги XDG
        # ======================================

        "Desktop"
        "Downloads"
        "Music"
        "Pictures"
        "Documents"
        "Videos"

        # .cache не на tmpfs — много приложений, объёмный дисковый кэш
        ".cache"

        # ======================================
        # Код / работа / черновики
        # ======================================
        "codes" # личные репозитории
        "work" # работа, отдельный .gitconfig
        "nix-config"
        "tmp"

        # ======================================
        # Nix / Home Manager
        # ======================================

        ".local/state/home-manager"
        ".local/state/nix/profiles"
        ".local/share/nix"

        # ======================================
        # IDE / редакторы
        # ======================================

        # neovim
        ".wakatime"

        # vscode
        ".vscode"
        ".config/Code"

        # Cursor (IDE / CLI)
        ".cursor"
        ".config/cursor"
        ".config/Cursor"

        # AI-агенты
        ".agents" # skills для агентов
        ".config/agents"
        ".claude"
        ".gemini"
        ".codex"
        ".config/opencode"
        ".local/share/opencode"
        ".local/state/opencode"
        ".kimi" # kimi-cli
        ".context7" # актуальные docs/примеры для LLM и агентов

        # nvim
        ".local/share/nvim"
        ".local/state/nvim"

        # helix + steel
        ".local/share/steel"

        # Joplin
        ".config/joplin" # TUI
        ".config/Joplin" # desktop

        ".local/share/jupyter"
        ".ipython"

        # ======================================
        # Cloud Native
        # ======================================
        {
          # pulumi — IaC
          directory = ".pulumi";
          mode = "0700";
        }
        {
          directory = ".aws";
          mode = "0700";
        }
        {
          directory = ".aliyun";
          mode = "0700";
        }
        {
          directory = ".config/gcloud";
          mode = "0700";
        }
        {
          directory = ".docker";
          mode = "0700";
        }
        {
          directory = ".kube";
          mode = "0700";
        }
        ".terraform.d/plugin-cache" # кэш плагинов terraform

        # ======================================
        # Менеджеры пакетов языков
        # ======================================
        ".npm" # TypeScript/JavaScript
        "go"
        ".cargo" # rust
        ".m2" # maven
        ".gradle" # gradle
        ".conda" # из `conda-shell`
        # pipx
        ".local/pipx"
        ".local/bin"
        # uv
        ".local/share/uv"

        # ======================================
        # Безопасность
        # ======================================

        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".pki";
          mode = "0700";
        }
        {
          directory = ".local/share/password-store";
          mode = "0700";
        }
        {
          # GNOME keyrings
          directory = ".local/share/keyrings";
          mode = "0700";
        }

        # ======================================
        # Игры / медиа
        # ======================================

        "Games"
        ".steam"
        ".config/blender"
        ".config/LDtk"
        ".config/heroic"
        ".config/lutris"
        ".local/share/umu"

        ".local/share/Steam"
        ".local/state/Heroic"

        ".local/share/lutris"
        ".local/share/tiled"
        ".local/share/GOG.com"
        ".local/share/StardewValley"
        ".local/share/feral-interactive"

        # ======================================
        # Встречи / удалёнка / запись
        # ======================================
        ".zoom"
        ".config/obs-studio"
        ".config/sunshine"
        ".config/freerdp"

        ".config/remmina"
        ".local/share/remmina"

        # ======================================
        # Браузеры
        # ======================================
        ".mozilla"
        ".config/google-chrome"
        ".config/chromium"

        # ======================================
        # Данные CLI
        # ======================================
        ".local/share/atuin"
        ".local/share/zoxide"
        ".local/share/direnv"
        ".local/share/k9s"

        # ======================================
        # Контейнеры
        # ======================================
        ".local/share/containers"
        ".local/share/flatpak"
        # данные flatpak / nixpak
        {
          directory = ".var";
          mode = "0700";
        }

        # ======================================
        # Прочее
        # ======================================

        # Clash Verge Rev
        ".local/share/io.github.clash-verge-rev.clash-verge-rev"
        ".local/share/clash-verge"

        # звук
        ".config/pulse"
        ".local/state/wireplumber"

        # цифровая живопись
        ".local/share/krita"

        # японский IME
        ".config/mozc" # fcitx5-mozc

        ".config/nushell"
      ];
      files = [
        {
          file = ".wakatime.cfg";
          how = "symlink";
        }
        {
          file = ".config/zoomus.conf";
          how = "symlink";
        }
        {
          file = ".config/zoom.conf";
          how = "symlink";
        }
        {
          file = ".claude.json";
          how = "bindmount";
        }
      ];
    };
  };

  # Каталоги с нужными правами.
  #
  # Здесь `/home/butz/.local` не родитель сохранённого файла —
  # tmpfiles создал бы root:root 0755, пользователь не сможет писать внутрь.
  #
  # systemd-tmpfiles задаёт владельца и mode.
  #
  # Родители сохранённых файлов — через `parent` и `configureParent = true`.
  systemd.tmpfiles.settings.preservation =
    let
      permission = {
        user = username;
        group = lib.mkForce username;
        mode = lib.mkForce "0750";
      };
    in
    {
      "/home/${username}/.config".d = permission;
      "/home/${username}/.local".d = permission;
      "/home/${username}/.local/share".d = permission;
      "/home/${username}/.local/state".d = permission;
      "/home/${username}/.local/state/nix".d = permission;
      "/home/${username}/.terraform.d".d = permission;
    };

  # systemd-machine-id-commit здесь не нужен при persistent machine-id
  #
  # см. пример firstboot в документации модуля
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # закоммитить transient ID на persistent том
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };
}
