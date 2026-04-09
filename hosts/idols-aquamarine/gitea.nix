{ pkgs, ... }:
{
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/misc/gitea.nix
  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/data/apps/gitea";
    appName = "Ryan Yin's Gitea Service";
    lfs.enable = true;
    # таймер `gitea dump` — бэкап БД и репозиториев
    dump = {
      enable = false;
      interval = "hourly";
      file = "gitea-dump";
      type = "tar.zst";
    };
    # файл с паролем SMTP
    # mailerPasswordFile = "";
    settings = {
      server = {
        SSH_PORT = 2222;
        PROTOCOL = "http";
        HTTP_PORT = 3301;
        HTTP_ADDR = "127.0.0.1";
        DOMAIN = "git.writefor.fun";
        ROOT_URL = "https://git.writefor.fun/";
      };
      # уровень: Trace, Debug, Info, Warn, Error, Critical
      log.LEVEL = "Info";
      # Secure cookie — только по HTTPS
      session.COOKIE_SECURE = true;
      # NOTE: первый зарегистрированный пользователь = admin;
      # не включать до регистрации первого пользователя!
      service.DISABLE_REGISTRATION = true;
      # https://docs.gitea.com/administration/config-cheat-sheet#security-security
      security = {
        LOGIN_REMEMBER_DAYS = 31;
        PASSWORD_HASH_ALGO = "scrypt";
        MIN_PASSWORD_LENGTH = 10;
      };

      # "cron.sync_external_users" = {
      #   RUN_AT_START = true;
      #   SCHEDULE = "@every 24h";
      #   UPDATE_EXISTING = true;
      # };
      mailer = {
        ENABLED = true;
        MAILER_TYPE = "sendmail";
        FROM = "do-not-reply@writefor.fun";
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
    };
    database = {
      type = "sqlite3";
      # создать локальную БД автоматически
      createDatabase = true;
    };
  };

  # services.gitea-actions-runner.instances."default" = {
  #   enable = true;
  #   name = "default";
  #   labels = [
  #     # debian + node для actions
  #     "debian-latest:docker://node:18-bullseye"
  #     # метка ubuntu-latest без официального ubuntu-образа node
  #     "ubuntu-latest:docker://node:18-bullseye"
  #     # нативный runner на хосте
  #     "native:host"
  #   ];
  #   gitea = "http://git.writefor.fun";
  #   # env-файл с TOKEN для регистрации runner
  #   tokenFile = "xxx"; # agenix
  #   # конфиг act_runner
  #   # https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml
  #   settings = {};
  #   # пакеты для label native:host
  #   hostPackages = with pkgs; [
  #     bash
  #     coreutils
  #     curl
  #     gawk
  #     gitMinimal
  #     gnused
  #     nodejs
  #     wget
  #   ];
  # };
}
