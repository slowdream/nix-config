{
  pkgs,
  config,
  wallpapers,
  ...
}:
let
  hostCommonConfig = ''
    encode zstd gzip
    tls ${../../certs/ecc-server.crt} ${config.age.secrets."caddy-ecc-server.key".path} {
      protocols tls1.3 tls1.3
      curves x25519 secp384r1 secp521r1
    }
  '';
in
{
  services.caddy = {
    enable = true;
    # reload вместо restart при смене конфига
    enableReload = true;
    user = "caddy"; # пользователь процесса caddy
    dataDir = "/data/apps/caddy";
    logDir = "/var/log/caddy";

    # доп. строки в global Caddyfile
    # https://caddyserver.com/docs/caddyfile/options#global-options
    globalConfig = ''
      http_port    80
      https_port   443
      auto_https   disable_certs
    '';

    # дашборд (homepage)
    virtualHosts."home.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      reverse_proxy http://localhost:54401
    '';

    # https://caddyserver.com/docs/caddyfile/directives/file_server
    virtualHosts."file.writefor.fun".extraConfig = ''
      root * /data/apps/caddy/fileserver/
      ${hostCommonConfig}
      file_server browse {
        hide .git
        precompressed zstd br gzip
      }
    '';

    virtualHosts."git.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3301
    '';
    virtualHosts."sftpgo.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3302
    '';
    virtualHosts."webdav.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3303
    '';
    virtualHosts."transmission.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9091
    '';

    # мониторинг
    virtualHosts."uptime-kuma.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:53350
    '';
    virtualHosts."grafana.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:3351
    '';
    virtualHosts."prometheus.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9090
    '';
    virtualHosts."alertmanager.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9093
    '';
    virtualHosts."vmalert.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:8880
    '';
    virtualHosts."minio.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9096 {
        header_up Host {http.request.host}
        header_up X-Real-IP {http.request.remote.host}
        header_up X-Forwarded-For {http.request.header.X-Forwarded-For}
        header_up X-Forwarded-Proto {scheme}
        transport http {
            dial_timeout 300s
            read_timeout 300s
            write_timeout 300s
        }
      }
    '';
    virtualHosts."minio-ui.writefor.fun".extraConfig = ''
      ${hostCommonConfig}
      encode zstd gzip
      reverse_proxy http://localhost:9097 {
        header_up Host {http.request.host}
        header_up X-Real-IP {http.request.remote.host}
        header_up X-Forwarded-For {http.request.header.X-Forwarded-For}
        header_up X-Forwarded-Proto {scheme}
        header_up Upgrade {http.request.header.Upgrade}
        header_up Connection {http.request.header.Connection}
        transport http {
            dial_timeout 300s
            read_timeout 300s
            write_timeout 300s
        }
      }
    '';
    # HTTP без редиректа на HTTPS для отдельных API
    # virtualHosts."http://xxx.writefor.fun/a/b/c".extraConfig = ''
    #   encode zstd gzip
    #   reverse_proxy http://localhost:9090
    # '';
  };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # Каталоги
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d /data/apps/caddy/fileserver/ 0755 caddy caddy"
    # образы VM
    "d /data/apps/caddy/fileserver/vms 0755 caddy caddy"
  ];

  # обои → fileserver/wallpapers
  system.activationScripts.installCaddyWallpapers = ''
    mkdir -p /data/apps/caddy/fileserver/wallpapers
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F644 ${wallpapers}/ /data/apps/caddy/fileserver/wallpapers/
  '';
}
