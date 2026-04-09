{
  # dae на aquamarine не даёт HTTP/SOCKS — здесь v2ray
  # https://github.com/v2fly
  services.v2ray = {
    enable = true;
    config = {
      # для мониторинга
      "stats" = { };
      "api" = {
        "tag" = "api";
        "services" = [
          "StatsService"
        ];
      };
      "policy" = {
        "levels" = {
          "0" = {
            "statsUserUplink" = true;
            "statsUserDownlink" = true;
          };
        };
        "system" = {
          "statsInboundUplink" = true;
          "statsInboundDownlink" = true;
          "statsOutboundUplink" = true;
          "statsOutboundDownlink" = true;
        };
      };

      inbounds = [
        # основной inbound
        {
          listen = "0.0.0.0";
          port = 7890;
          protocol = "http";
        }
        {
          listen = "0.0.0.0";
          port = 7891;
          protocol = "socks";
          settings = {
            auth = "noauth";
            udp = true;
          };
        }

        # для мониторинга
        {
          "tag" = "api";
          "listen" = "127.0.0.1";
          "port" = 54321;
          "protocol" = "dokodemo-door";
          "settings" = {
            "address" = "127.0.0.1";
          };
        }
      ];
      outbounds = [
        # напрямую в сеть (к dae на aquamarine)
        {
          protocol = "freedom";
          tag = "freedom";
        }
      ];

      # для мониторинга
      "routing" = {
        "rules" = [
          {
            "inboundTag" = [
              "api"
            ];
            "outboundTag" = "api";
            "type" = "field";
          }
        ];
      };
    };
  };

  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/monitoring/prometheus/exporters/v2ray.nix
  # https://github.com/wi1dcard/v2ray-exporter
  services.prometheus.exporters.v2ray = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9153;
    openFirewall = false;
    v2rayEndpoint = "127.0.0.1:54321";
  };
}
