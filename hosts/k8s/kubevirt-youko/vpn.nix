{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.tailscale ];

  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # UDP-порт Tailscale в firewall
    openFirewall = true;

    useRoutingFeatures = "server";
    extraSetFlags = [
      # анонсировать homelab-подсеть через tailscale
      "--advertise-routes=192.168.5.0/24"
      "--accept-routes=false"
    ];
  };
}
