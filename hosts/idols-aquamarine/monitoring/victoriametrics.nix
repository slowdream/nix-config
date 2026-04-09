{
  lib,
  myvars,
  ...
}:
{
  # VictoriaMetrics с DynamicUser — до старта сервиса user/group нет.
  # Доп. группа для доступа к /data/apps/…
  users.groups.victoriametrics-data = { };

  # Каталог данных вне дефолта
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /data/apps/victoriametrics 0770 root victoriametrics-data - -"
  ];

  # С symlink DynamicUser не работает — bind mount
  # https://github.com/systemd/systemd/issues/25097#issuecomment-1929074961
  systemd.services.victoriametrics.serviceConfig = {
    SupplementaryGroups = [ "victoriametrics-data" ];
    BindPaths = [ "/data/apps/victoriametrics:/var/lib/victoriametrics:rbind" ];
  };

  # https://victoriametrics.io/docs/victoriametrics/latest/configuration/configuration/
  services.victoriametrics = {
    enable = true;
    listenAddress = "127.0.0.1:9090";
    retentionPeriod = "30d";

    extraOptions = [
      # лимит RAM под кэши VM (%)
      "-memory.allowedPercent=50"
    ];
    stateDir = "victoriametrics";

    # scrape_configs Prometheus-формата
    # https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
    prometheusConfig = {
      scrape_configs = [
        # --- приложения homelab --- #

        {
          job_name = "dnsmasq-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.suzi.ipv4}:9153" ];
              labels.type = "app";
              labels.app = "dnsmasq";
              labels.host = "suzi";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }

        {
          job_name = "v2ray-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:9153" ];
              labels.type = "app";
              labels.app = "v2ray";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "postgres-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:9187" ];
              labels.type = "app";
              labels.app = "postgresql";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "sftpgo-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "${myvars.networking.hostsAddr.aquamarine.ipv4}:10000" ];
              labels.type = "app";
              labels.app = "sftpgo";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "alertmanager-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              targets = [ "localhost:9093" ];
              labels.type = "app";
              labels.app = "alertmanager";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
        {
          job_name = "victoriametrics-embedded-exporter";
          scrape_interval = "30s";
          metrics_path = "/metrics";
          static_configs = [
            {
              # self-scrape самой VictoriaMetrics
              targets = [ "localhost:9090" ];
              labels.type = "app";
              labels.app = "victoriametrics";
              labels.host = "aquamarine";
              labels.env = "homelab";
              labels.cluster = "homelab";
            }
          ];
        }
      ]
      # --- Хосты --- #
      ++ (lib.attrsets.foldlAttrs (
        acc: hostname: addr:
        acc
        ++ [
          {
            job_name = "node-exporter-${hostname}";
            scrape_interval = "30s";
            metrics_path = "/metrics";
            static_configs = [
              {
                # все NixOS-хосты из myvars
                targets = [ "${addr.ipv4}:9100" ];
                labels.type = "node";
                labels.host = hostname;
                labels.env = "homelab";
                labels.cluster = "homelab";
              }
            ];
          }
        ]
      ) [ ] myvars.networking.hostsAddr);
    };
  };
}
