{
  config,
  pkgs,
  lib,
  myvars,
  ...
}:
let
  inherit (myvars) username;

  user = "postgres"; # системный пользователь PostgreSQL по умолчанию
  package = pkgs.postgresql_16;
  dataDir = "/data/apps/postgresql/${package.psqlSchema}";
in
{
  # Каталоги
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /data/apps/postgresql 0700 ${user} ${user}"
    "d ${dataDir} 0700 ${user} ${user}"
  ];

  # https://wiki.nixos.org/wiki/PostgreSQL
  # https://search.nixos.org/options?channel=unstable&query=services.postgresql.
  # https://www.postgresql.org/docs/
  services.postgresql = {
    enable = true;
    inherit package dataDir;
    # https://www.postgresql.org/docs/16/jit.html
    # JIT выгоден для долгих CPU-bound запросов (аналитика); на коротких оверхед JIT может перевесить выигрыш.
    enableJIT = true;
    enableTCPIP = true;

    # БД из списка будут созданы
    ensureDatabases = [
      "playground" # тесты
    ];
    ensureUsers = [
      {
        name = "playground";
        ensureDBOwnership = true;
      }
    ];
    initdbArgs = [
      "--data-checksums"
      "--allow-group-access"
    ];

    extraPlugins =
      ps: with ps; [
        # postgis
        # pg_repack
      ];

    # https://www.postgresql.org/docs/16/runtime-config.html
    settings = {
      port = 5432;
      # соединения
      max_connections = 100;

      # логи
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";

      # ssl
      ssl = true;
      ssl_cert_file = "${../../certs/ecc-server.crt}";
      ssl_key_file = config.age.secrets."postgres-ecc-server.key".path;
      ssl_min_protocol_version = "TLSv1.3";
      ssl_ecdh_curve = "secp384r1";
      # Свои DH-параметры снижают риск (слабые группы)
      # dhparam -out dhparams.pem 2048
      # ssl_dh_params_file = "";

      # память
      shared_buffers = "128MB";
      huge_pages = "try";
    };

    # systemUser → DBUser
    # root и свой пользователь: `psql -U postgres` без лишней auth
    identMap = ''
      # ArbitraryMapName systemUser          DBUser
      superuser_map      root                postgres
      superuser_map      postgres            postgres
      superuser_map      postgres-exporter   postgres
      superuser_map      ${username}         postgres
      # остальные логинятся как сами себе
      superuser_map      /^(.*)$             \1
    '';

    # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD   OPTIONS

      # только Unix socket
      local   all             all                                     peer     map=superuser_map
      # IPv4 localhost:
      host    all             all             127.0.0.1/32            trust
      # IPv6 localhost:
      host    all             all             ::1/128                 trust

      # replication с localhost
      local   replication     all                                     trust
      host    replication     all             127.0.0.1/32            trust
      host    replication     all             ::1/128                 trust

      # удалённо — только БД с тем же именем, что и пользователь (sameuser)
      host    sameuser        all             0.0.0.0/0               scram-sha-256
    '';
    # initialScript =
    #   pkgs.writeText "backend-initScript" ''
    #   '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9187;
    user = "postgres-exporter";
    group = "postgres-exporter";
    dataSourceName = "user=postgres database=postgres host=/run/postgresql sslmode=verify-full";
  };
}
