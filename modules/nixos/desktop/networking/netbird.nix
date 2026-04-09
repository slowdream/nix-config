{
  lib,
  pkgs,
  ...
}:
# =============================================================
#
# NetBird — приватная сеть (VPN) на WireGuard, Coturn и др.
#
# Похож на tailscale, но более open source и менее зрелый.
#
# Нативно поддерживает несколько клиентов на одном хосте — у Tailscale это сложнее.
# Модуль NixOS даёт отдельный CLI wrapper на клиент — управление проще.
#
# Как пользоваться:
#  1. Аккаунт: https://app.netbird.io/
#  2. Вход и сеть homelab: `netbird-homelab up`
#
# Статус и данные:
#   `journalctl -u netbird-homelab` — логи netbird
#   данные в /var/lib/netbird-homelab и /etc/netbird-homelab
#   (persistent между перезагрузками через preservation)
#
# Ссылки:
#  https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/netbird.nix
#
# =============================================================
{
  # services.netbird.useRoutingFeatures = "client";
  # services.netbird.clients.homelab = {
  #   port = 51820;
  #   name = "homelab";
  #   interface = "netbird-homelab";
  #   hardened = true;
  #   autoStart = true;
  # };
}
