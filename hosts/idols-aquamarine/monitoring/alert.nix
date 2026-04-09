{ config, ... }:
{
  # https://docs.victoriametrics.com/victoriametrics/vmalert/
  services.vmalert.instances."homelab" = {
    enable = true;
    settings = {
      "httpListenAddr" = "127.0.0.1:8880";

      "datasource.url" = "http://localhost:9090";
      "notifier.url" = [ "http://localhost:9093" ]; # эндпойнт Alertmanager API
      # recording rules и remote write (куда пишутся метрики)
      "remoteWrite.url" = "http://localhost:9090";
      "remoteRead.url" = "http://localhost:9090";

      # не держать долгие keep-alive к datasource
      "datasource.disableKeepAlive" = true;
      # не маскировать URL с паролями в логах/UI/metrics
      "datasource.showURL" = false;
      # файлы alerting / recording rules
      rule = [
        "${./alert_rules}/*.yml"
        "${./recoding_rules}/*.yml"
      ];
      # https://docs.victoriametrics.com/victoriametrics/vmalert/#link-to-alert-source
      # для корректного `.GeneratorURL`
      "external.url" = "https://grafana.writefor.fun";
      "external.alert.source" =
        ''explore?left={"datasource":"{{ if eq .Type \"vlogs\" }}VictoriaLogs{{ else }}VictoriaMetrics{{ end }}","queries":[{"expr":{{ .Expr|jsonEscape|queryEscape }},"refId":"A"}],"range":{"from":"{{ .ActiveAt.UnixMilli }}","to":"now"}}'';
    };
  };

  services.prometheus.alertmanager = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9093;
    webExternalUrl = "http://alertmanager.writefor.fun";
    logLevel = "info";
    environmentFile = config.age.secrets."alertmanager.env".path;
    configuration = {
      global = {
        # SMTP smarthost и отправитель
        smtp_smarthost = "smtp.qq.com:465";
        smtp_from = "$SMTP_SENDER_EMAIL";
        smtp_auth_username = "$SMTP_AUTH_USERNAME";
        smtp_auth_password = "$SMTP_AUTH_PASSWORD";
        # smtp.qq.com:465 — SSL; TLS STARTTLS отключаем
        # https://service.mail.qq.com/detail/0/310
        smtp_require_tls = false;
      };
      route = {
        receiver = "telegram";
        routes = [
          {
            receiver = "telegram";
            # группировка по labels
            group_by = [
              "job"
              # --- метки алертов ---
              "alertname"
              "alertgroup"
              # --- метки Kubernetes ---
              "namespace"
              # --- свои метки ---
              "cluster"
              "env"
              "type"
            ];
            group_wait = "3m"; # подождать группировку перед отправкой
            group_interval = "5m"; # интервал между алертами той же группы
            repeat_interval = "5h"; # не спамить повтором
          }
          # {
          #   # только critical из prd → email
          #   match = {
          #     severity = "critical";
          #     env = "prd";
          #   };
          #   receiver = "email";
          #   group_by = [
          #     "host"
          #     "namespace"
          #     "pod"
          #     "job"
          #   ];
          #   group_wait = "1m";
          #   group_interval = "5m";
          #   repeat_interval = "2h";
          # }
        ];
      };
      receivers = [
        # {
        #   name = "email";
        #   email_configs = [
        #     {
        #       to = "ryan4yin@linux.com";
        #       # уведомлять о resolved
        #       send_resolved = true;
        #     }
        #   ];
        # }
        {
          name = "telegram";
          telegram_configs = [
            {
              bot_token = "$TELEGRAM_BOT_TOKEN";
              chat_id = 586169186; # ID чата в Telegram
              # уведомлять о resolved
              send_resolved = true;
              # не отключать уведомления для resolved
              disable_notifications = false;
              # Markdown в Telegram неудобен — HTML
              # https://core.telegram.org/bots/api#formatting-options
              parse_mode = "HTML";
              # шаблон сообщения
              message = ''
                {{- if eq .Status "firing" }}
                🟡 <b>告警触发</b>  {{ .CommonLabels.alertname }} [{{ index .CommonLabels "severity" | title }}]
                {{- else }}
                🟢 <b>告警恢复</b>  {{ .CommonLabels.alertname }} [{{ index .CommonLabels "severity" | title }}]
                {{- end }}

                {{- range .Alerts }}

                📊 <b>详情:</b>
                • <b>告警组</b>: {{ .Labels.alertgroup }}
                • <b>等级</b>: {{ if eq .Labels.severity "critical" }}🔴{{ else }}🟡 {{ end }} {{ .Labels.severity | title }}
                • <b>查询</b>: <a href="{{ .GeneratorURL }}">Grafana Explore</a>
                • <b>触发值</b>: {{ with .Annotations.value }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Env</b>: {{ with .Labels.env }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Cluster</b>: {{ with .Labels.cluster }}{{ . }}{{ else }}N/A{{ end }}
                • <b>Namespace</b>: {{ with .Labels.namespace }}{{ . }}{{ else }}N/A{{ end }}
                • <b>标签</b>: {{ range .Labels.SortedPairs }}{{ .Name }}={{ .Value }},{{ end }}
                • <b>触发时间</b>: {{ .StartsAt.Format "2006-01-02 15:04:05" }}
                {{- end }}
              '';
            }
          ];
        }
      ];
    };
  };
}
