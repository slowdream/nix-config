{
  lib,
  config,
  pkgs,
  agenix,
  mysecrets,
  myvars,
  ...
}:
with lib;
let
  cfg = config.modules.secrets;

  enabledServerSecrets =
    cfg.server.application.enable
    || cfg.server.network.enable
    || cfg.server.operation.enable
    || cfg.server.kubernetes.enable
    || cfg.server.webserver.enable
    || cfg.server.storage.enable;

  noaccess = {
    mode = "0000";
    owner = "root";
  };
  high_security = {
    mode = "0500";
    owner = "root";
  };
  user_readable = {
    mode = "0500";
    owner = myvars.username;
  };
in
{
  imports = [
    agenix.nixosModules.default
  ];

  options.modules.secrets = {
    desktop.enable = mkEnableOption "NixOS Secrets for Desktops";

    server.network.enable = mkEnableOption "NixOS Secrets for Network Servers";
    server.application.enable = mkEnableOption "NixOS Secrets for Application Servers";
    server.operation.enable = mkEnableOption "NixOS Secrets for Operation Servers(Backup, Monitoring, etc)";
    server.kubernetes.enable = mkEnableOption "NixOS Secrets for Kubernetes";
    server.webserver.enable = mkEnableOption "NixOS Secrets for Web Servers(contains tls cert keys)";
    server.storage.enable = mkEnableOption "NixOS Secrets for HDD Data's LUKS Encryption";

    preservation.enable = mkEnableOption "whether use preservation and ephemeral root file system";
  };

  config = mkIf (cfg.desktop.enable || enabledServerSecrets) (mkMerge [
    {
      environment.systemPackages = [
        agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
      ];

      # если ключ сменили — перегенерируйте все .age из расшифрованного содержимого
      age.identityPaths =
        if cfg.preservation.enable then
          [
            # Для decrypt secrets при boot ключ должен существовать при загрузке,
            # поэтому здесь реальный путь к файлу ключа (с префиксом `/persistent/`), а не путь, смонтированный preservation.
            "/persistent/etc/ssh/ssh_host_ed25519_key" # Linux
          ]
        else
          [
            "/etc/ssh/ssh_host_ed25519_key"
          ];

      # secrets, общие для всех nixos hosts
      age.secrets = {
        "nix-access-tokens" = {
          file = "${mysecrets}/nix-access-tokens.age";
        }
        # access-token должен читать пользователь, под которым идёт команда `nix`
        // user_readable;
      };

      assertions = [
        {
          # Выражение должно быть true, иначе assertion не пройдёт
          assertion = !(cfg.desktop.enable && enabledServerSecrets);
          message = "Enable either desktop or server's secrets, not both!";
        }
      ];
    }

    (mkIf cfg.desktop.enable {
      age.secrets = {
        # ---------------------------------------------
        # никто не может читать/писать файл, даже root
        # ---------------------------------------------

        # .age: расшифрованный файл всё ещё зашифрован age (passphrase)
        "ryan4yin-gpg-subkeys.priv.age" = {
          file = "${mysecrets}/ryan4yin-gpg-subkeys-2024-01-27.priv.age.age";
        }
        // noaccess;

        # Только для NixOS modules

        # ссылка в /etc/fstab для mount davfs volume
        "davfs-secrets" = {
          file = "${mysecrets}/davfs-secrets.age";
        }
        // high_security;

        "rclone.conf" = {
          file = "${mysecrets}/rclone.conf.age";
        }
        // high_security;

        # ---------------------------------------------
        # пользователь может читать файл
        # ---------------------------------------------

        "ssh-key-romantic" = {
          file = "${mysecrets}/ssh-key-romantic.age";
        }
        // user_readable;

        # alias-for-work
        "alias-for-work.nushell" = {
          file = "${mysecrets}/alias-for-work.nushell.age";
        }
        // user_readable;
      };

      # secrets в /etc/
      environment.etc = {
        "agenix/rclone.conf" = {
          source = config.age.secrets."rclone.conf".path;
        };

        "agenix/ssh-key-romantic" = {
          source = config.age.secrets."ssh-key-romantic".path;
          mode = "0600";
          user = myvars.username;
        };

        "agenix/ryan4yin-gpg-subkeys.priv.age" = {
          source = config.age.secrets."ryan4yin-gpg-subkeys.priv.age".path;
          mode = "0000";
        };

        # Следующие secrets используются home-manager модулями
        # — сделать читаемыми для пользователя
        "agenix/alias-for-work.nushell" = {
          source = config.age.secrets."alias-for-work.nushell".path;
          mode = "0644"; # и оригинал, и symlink должны быть readable (и executable) для пользователя
        };
      };
    })

    (mkIf cfg.server.network.enable {
      age.secrets = {
        "dae-subscription.dae" = {
          file = "${mysecrets}/server/dae-subscription.dae.age";
        }
        // high_security;
      };
    })

    (mkIf cfg.server.application.enable {
      age.secrets = {
        "transmission-credentials.json" = {
          file = "${mysecrets}/server/transmission-credentials.json.age";
        }
        // high_security;

        "sftpgo.env" = {
          file = "${mysecrets}/server/sftpgo.env.age";
          mode = "0400";
          owner = "sftpgo";
        };
        "minio.env" = {
          file = "${mysecrets}/server/minio.env.age";
          mode = "0400";
          owner = "minio";
        };
      };
    })

    (mkIf cfg.server.operation.enable {
      age.secrets = {
        "grafana-admin-password" = {
          file = "${mysecrets}/server/grafana-admin-password.age";
          mode = "0400";
          owner = "grafana";
        };
        "grafana-secret-key" = {
          file = "${mysecrets}/server/grafana-secret-key.age";
          mode = "0400";
          owner = "grafana";
        };

        "alertmanager.env" = {
          file = "${mysecrets}/server/alertmanager.env.age";
        }
        // high_security;
      };
    })

    (mkIf cfg.server.kubernetes.enable {
      age.secrets = {
        "k3s-prod-1-token" = {
          file = "${mysecrets}/server/k3s-prod-1-token.age";
        }
        // high_security;

        "k3s-test-1-token" = {
          file = "${mysecrets}/server/k3s-test-1-token.age";
        }
        // high_security;
      };
    })

    (mkIf cfg.server.webserver.enable {
      age.secrets = {
        "caddy-ecc-server.key" = {
          file = "${mysecrets}/certs/ecc-server.key.age";
          mode = "0400";
          owner = "caddy";
        };
        "postgres-ecc-server.key" = {
          file = "${mysecrets}/certs/ecc-server.key.age";
          mode = "0400";
          owner = "postgres";
        };
      };
    })

    (mkIf cfg.server.storage.enable {
      age.secrets = {
        "hdd-luks-crypt-key" = {
          file = "${mysecrets}/hdd-luks-crypt-key.age";
          mode = "0400";
          owner = "root";
        };
      };

      # secrets в /etc/
      environment.etc = {
        "agenix/hdd-luks-crypt-key" = {
          source = config.age.secrets."hdd-luks-crypt-key".path;
          mode = "0400";
          user = "root";
        };
      };
    })
  ]);
}
