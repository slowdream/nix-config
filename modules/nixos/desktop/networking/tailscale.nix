{
  lib,
  pkgs,
  ...
}:
# =============================================================
#
# Tailscale — приватная сеть (VPN) на WireGuard
#
# Open source, бесплатно для личного использования,
# простой setup. Клиенты: Linux, Windows, Mac, Android, iOS.
# Зрелее и стабильнее многих альтернатив (netbird, netmaker и т.п.).
#
# Как пользоваться:
#  1. Аккаунт: https://login.tailscale.com
#  2. Вход: `tailscale login`
#  3. В сеть: `tailscale up --accept-routes`
#  4. Автоподключение: опция `authKeyFile` в конфиге ниже.
#
# Статус и данные:
#   `journalctl -u tailscaled` — логи tailscaled
#   данные в /var/lib/tailscale (persistent между перезагрузками через preservation)
#
# Ссылки:
# https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/networking/tailscale.nix
#
# =============================================================
{
  # команда tailscale в PATH для пользователей
  environment.systemPackages = [ pkgs.tailscale ];

  # сервис tailscale
  services.tailscale = {
    enable = true;
    port = 41641;
    interfaceName = "tailscale0";
    # открыть UDP-порт Tailscale в firewall
    openFirewall = true;

    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes"
    ];
  };
}
