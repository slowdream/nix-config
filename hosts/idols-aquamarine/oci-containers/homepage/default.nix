{
  config,
  pkgs,
  ...
}:
let
  user = "homepage";
  configDir = "/data/apps/homepage-dashboard";
in
{
  users.groups.${user} = { };
  users.users.${user} = {
    group = user;
    home = configDir;
    isSystemUser = true;
  };

  # Раскладка конфигов homepage-dashboard
  system.activationScripts.installHomepageDashboardConfig = ''
    mkdir -p ${configDir}
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F644 ${./config}/ ${configDir}/
    chown -R ${user}:${user} ${configDir}
  '';

  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/virtualisation/oci-containers.nix
  virtualisation.oci-containers.containers = {
    # логи: `journalctl -u podman-homepage`
    homepage = {
      hostname = "homepage";
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "127.0.0.1:54401:3000" ];
      # https://github.com/gethomepage/homepage/wiki/Environment-Variables
      environment = {
        # "PUID" = config.users.users.${user}.uid;
        # "PGID" = config.users.groups.${user}.gid;
      };
      volumes = [
        "${configDir}:/app/config"
      ];
      autoStart = true;
    };
  };
}
