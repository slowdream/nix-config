{ config, ... }:
{

  # Декларативный provisioning datasource / дашбордов / правил.
  # Алертинг в Grafana не используем — Alertmanager.
  # https://grafana.com/docs/grafana/latest/administration/provisioning/#data-sources
  services.grafana.provision.datasources.settings = {
    apiVersion = 1;

    # Удалить эти datasource из БД Grafana
    deleteDatasources = [
      {
        name = "Loki";
        orgId = 1;
      }
    ];

    # Помечать provisioned datasource на удаление, если их нет в файле.
    # Игнорируется, если datasource уже в deleteDatasources.
    prune = true;

    datasources = [
      {
        # https://grafana.com/docs/grafana/latest/datasources/prometheus/configure/
        name = "prometheus-homelab";
        type = "prometheus";
        access = "proxy";
        # proxy — запросы с сервера Grafana; direct — из браузера
        url = "http://localhost:9090";
        jsonData = {
          httpMethod = "POST";
          manageAlerts = true;
          timeInterval = "15s";
          queryTimeout = "90s";
          prometheusType = "Prometheus";
          cacheLevel = "High";
          disableRecordingRules = false;
          # Grafana 10+: инкрементальные запросы для «живых» дашбордов
          # Больше incrementalQueryOverlapWindow — тяжелее запросы, но стабильнее свежие данные
          incrementalQueryOverlapWindow = "10m";
        };
        editable = false;
      }
      {
        # Плагин VictoriaMetrics — нативнее, чем чистый Prometheus
        name = "victoriametrics-homelab";
        type = "victoriametrics-metrics-datasource";
        access = "proxy";
        url = "http://localhost:9090";
        # url: http://vmselect:8481/select/0/prometheus  # кластер VM
        jsonData = {
          httpMethod = "POST";
          manageAlerts = true;
          timeInterval = "15s";
          queryTimeout = "90s";
          disableMetricsLookup = false; # автодополнение метрик
          vmuiUrl = "https://prometheus.writefor.fun/vmui/";
        };
        isDefault = true;
        editable = false;
      }
      {
        # https://grafana.com/docs/grafana/latest/datasources/loki/configure-loki-data-source/
        name = "loki-k3s-test-1";
        type = "loki";
        access = "proxy";
        url = "https://loki-gateway.writefor.fun";
        jsonData = {
          timeout = 30;
          maxLines = 1000;
          httpHeaderName1 = "X-Scope-OrgID";
        };
        secureJsonData = {
          httpHeaderValue1 = "fake";
        };
        editable = false;
      }
      {
        name = "alertmanager-homelab";
        type = "alertmanager";
        url = "http://localhost:9093";
        access = "proxy";
        jsonData = {
          implementation = "prometheus";
          handleGrafanaManagedAlerts = false;
        };
        editable = false;
      }
      {
        # https://grafana.com/docs/grafana/latest/datasources/postgres/configure/
        name = "postgres-playground";
        type = "postgres";
        url = "postgres.writefor.fun:5432";
        user = "playground";
        secureJsonData = {
          password = "$__file{${config.age.secrets."grafana-admin-password".path}}";
        };
        jsonData = {
          database = "playground";
          sslmode = "verify-full"; # значения: disable / require / verify-ca / verify-full
          maxOpenConns = 50;
          maxIdleConns = 250;
          maxIdleConnsAuto = true;
          connMaxLifetime = 14400;
          timeInterval = "1m";
          timescaledb = false;
          postgresVersion = 1500; # 15.x
          # TLS
          tlsConfigurationMethod = "file-path";
          sslRootCertFile = ../../../certs/ecc-ca.crt;
        };
        editable = false;
      }
      {
        name = "infinity-dataviewer";
        type = "yesoreyeram-infinity-datasource";
        editable = false;
      }
    ];

  };
}
