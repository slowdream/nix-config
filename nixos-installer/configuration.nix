{ pkgs, ... }:
{
  # ssh-agent — pull приватного secrets repo с GitHub при деплое
  programs.ssh.startAgent = true;

  # Пакеты в system profile. Поиск: nix search wget
  environment.systemPackages = with pkgs; [
    neovim # редактор для configuration.nix; nano тоже ставится по умолчанию
    git
    gnumake
    wget
    just # runner команд (иногда вместо gmake)
    curl
    nix-output-monitor
  ];
  networking = {
    # сеть (в т.ч. Wi‑Fi) через `nmcli` и `nmtui`
    networkmanager.enable = true;
  };
  system.stateVersion = "25.11";
}
