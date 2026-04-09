{ pkgs, ... }:
{
  # https://github.com/Mic92/nix-ld
  #
  # nix-ld в `/lib64/ld-linux-x86-64.so.2` как dynamic linker для бинарей не из NixOS.
  #
  # Прослойка между loader в `/nix/store/.../ld-linux-x86-64.so.2` и чужим ELF:
  #
  #   1. `NIX_LD` — путь к настоящему loader
  #   2. `NIX_LD_LIBRARY_PATH` → `LD_LIBRARY_PATH` для loader
  #
  # Модуль NixOS задаёт дефолты:
  #
  #  - https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/programs/nix-ld.nix#L37-L40
  #
  # `NIX_LD_LIBRARY_PATH` можно переопределить в окружении запуска.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
    ];
  };

  environment.systemPackages = with pkgs; [
    nodejs_24
    pnpm

    #-- python
    conda
    uv
    pipx
    (python313.withPackages (
      ps: with ps; [
        pandas
        requests
        pyquery
        pyyaml
        numpy

        # загрузчики моделей
        huggingface-hub
        modelscope
      ]
    ))

    rustc
    cargo
    go
  ];
}
