{
  pkgs,
  config,
  myvars,
  ...
}:
{

  imports = [
    ./dashboards.nix
    ./datasources.nix
  ];

  services.grafana = {
    enable = true;
    dataDir = "/data/apps/grafana";
    provision.enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3351;
        protocol = "http";
        domain = "grafana.writefo.fun";
        # редирект при несовпадении Host — защита от DNS rebinding
        serve_from_sub_path = false;
        # subpath в root_url, если serve_from_sub_path = true
        root_url = "%(protocol)s://%(domain)s:%(http_port)s/";
        enforce_domain = false;
        read_timeout = "180s";
        # gzip для HTTP
        enable_gzip = true;
        # CDN для статики фронта
        # cdn_url = "https://cdn.jsdelivr.net/npm/grafana@7.5.5";
      };

      security = {
        admin_user = myvars.username;
        admin_email = myvars.useremail;
        # пароль admin из файла (file provider)
        # https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#file-provider
        admin_password = "$__file{${config.age.secrets."grafana-admin-password".path}}";
        secret_key = "$__file{${config.age.secrets."grafana-secret-key".path}}";
      };
      users = {
        allow_sign_up = false;
        # home_page = "";
        default_theme = "dark";
      };
    };

    # https://github.com/NixOS/nixpkgs/tree/master/pkgs/servers/monitoring/grafana/plugins
    declarativePlugins = with pkgs.grafanaPlugins; [
      # https://github.com/VictoriaMetrics/victoriametrics-datasource
      # MetricsQL, шаблоны, tracing, prettify и т.д.
      victoriametrics-metrics-datasource
      # https://github.com/VictoriaMetrics/victorialogs-datasource
      victoriametrics-logs-datasource

      redis-app
      redis-datasource
      redis-explorer-app

      grafana-googlesheets-datasource
      grafana-github-datasource
      grafana-clickhouse-datasource
      grafana-mqtt-datasource
      frser-sqlite-datasource

      # https://github.com/grafana/grafana-infinity-datasource
      # JSON, CSV, XML, GraphQL, HTML в Grafana
      yesoreyeram-infinity-datasource

      # нет в nixpkgs: trino, advisor, llm, kafka
    ];
  };

  environment.etc."grafana/dashboards".source = ./dashboards;
}
