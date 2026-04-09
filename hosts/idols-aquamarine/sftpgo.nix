{ config, lib, ... }:
let
  user = "sftpgo";
  dataDir = "/data/apps/sftpgo";
in
{
  # SFTPGO_DEFAULT_ADMIN_USERNAME / SFTPGO_DEFAULT_ADMIN_PASSWORD из файла
  systemd.services.sftpgo.serviceConfig = {
    EnvironmentFile = config.age.secrets."sftpgo.env".path;
  };

  # Группа fileshare (user-group.nix) — общий доступ с transmission
  users.users.${user}.extraGroups = [ "fileshare" ];

  # Каталоги
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  # 2775 + setgid → новые файлы с группой fileshare
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${user} -"
  ];

  services.sftpgo = {
    enable = true;
    inherit user dataDir;
    extraReadWriteDirs = [
      "/data/fileshare"
    ];
    extraArgs = [
      "--log-level"
      "info"
    ];
    # https://github.com/drakkan/sftpgo/blob/2.5.x/docs/full-configuration.md
    settings = {
      common = {
        # defender: блокировки, DoS и brute-force
        defender = {
          enable = true;
        };
      };
      # данные SFTPGo
      data_provider = {
        driver = "sqlite";
        name = "sftpgo.db";
        password_hashing = {
          algo = "argon2id";
          # argon2id: память и итерации = стоимость хэша
          argon2_options = {
            memory = 65536; # KiB
            iterations = 2; # проходы по памяти
            parallelism = 2; # потоки (lanes)
          };
        };
        password_validation = {
          # энтропия пароля — ориентир 50–70
          # https://github.com/wagslane/go-password-validator#what-entropy-value-should-i-use
          admins.min_entropy = 60;
          users.min_entropy = 60;
        };
        # кэш хэшей паролей в RAM
        password_caching = true;
        # дефолтный admin из env
        # SFTPGO_DEFAULT_ADMIN_USERNAME and SFTPGO_DEFAULT_ADMIN_PASSWORD
        create_default_admin = true;
      };

      # WebDAV для файлов; по HTTPS в публичных сетях ок
      webdavd.bindings = [
        {
          address = "127.0.0.1";
          port = 3303;
        }
      ];
      # HTTP — админка и клиент
      httpd.bindings = [
        {
          address = "127.0.0.1";
          enable_https = false;
          port = 3302;
          client_ip_proxy_header = "X-Forwarded-For";
          # веб-админка: пользователи, VFS, админы, сессии
          # url: http://127.0.0.1:8080/web/admin
          enable_web_admin = true;
          # веб-клиент для пользователей
          enable_web_client = true;
          enable_rest_api = true;
        }
      ];
      # метрики для Prometheus
      telemetry = {
        bind_port = 10000;
        bind_address = "0.0.0.0";
        # auth_user_file = "";
      };
      # двухфакторка (MFA, TOTP)
      mfa.totp = [
        {
          # имя конфига, не видно в приложениях; не менять после первого пользователя
          name = "SFTPGo";
          # issuer для TOTP
          issuer = "SFTPGo";
          # HMAC для TOTP
          # Google Authenticator на iPhone часто только sha1
          algo = "sha1";
        }
      ];
      # SMTP для писем из SFTPGo
      # smtp = {};
    };
  };
}
