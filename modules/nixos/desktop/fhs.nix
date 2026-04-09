{ pkgs, ... }:
{
  # FHS environment, flatpak, appImage и т.д.
  environment.systemPackages = [
    # создать FHS environment командой `fhs`, чтобы запускать non-NixOS пакеты на NixOS
    (
      let
        base = pkgs.appimageTools.defaultFhsEnvArgs;
      in
      pkgs.buildFHSEnv (
        base
        // {
          name = "fhs";
          targetPkgs = pkgs: (base.targetPkgs pkgs) ++ [ pkgs.pkg-config ];
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = [ "dev" ];
        }
      )
    )
  ];

  # https://github.com/Mic92/nix-ld
  #
  # nix-ld ставит себя в `/lib64/ld-linux-x86-64.so.2`, чтобы
  # выступать dynamic linker для бинарников не из NixOS.
  #
  # nix-ld работает как middleware между реальным link loader в `/nix/store/.../ld-linux-x86-64.so.2`
  # и бинарниками не из NixOS. Он:
  #
  #   1. читает переменную окружения `NIX_LD` и по ней находит реальный link loader.
  #   2. читает `NIX_LD_LIBRARY_PATH` и задаёт `LD_LIBRARY_PATH` для реального link loader.
  #
  # модуль nix-ld в NixOS задаёт дефолты для `NIX_LD` и `NIX_LD_LIBRARY_PATH`, чтобы
  # всё работало из коробки:
  #
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/programs/nix-ld.nix#L37-L40
  #
  # Можно переопределить `NIX_LD_LIBRARY_PATH` в окружении, где запускаются бинарники, чтобы настроить
  # search path для shared libraries.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };
}
