{ lib, ... }:
{
  # Либо отключить firewall целиком.
  networking.firewall.enable = lib.mkDefault false;
  # OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      # root нужен для remote deploy
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false; # без пароля по SSH
    };
    openFirewall = true;
  };

  # terminfo для известных терминалов в system profile
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;
}
