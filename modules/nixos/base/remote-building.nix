{ myvars, ... }:
{
  ####################################################################
  #
  #  NixOS: remote / distributed building
  #
  #  Доки:
  #    1. https://github.com/NixOS/nix/issues/7380
  #    2. https://nixos.wiki/wiki/Distributed_build
  #    3. https://github.com/NixOS/nix/issues/2589
  #
  ####################################################################

  # max-jobs = 0 — только remote build (без локальной сборки)
  # nix.settings.max-jobs = 0;
  nix.distributedBuilds = true;
  nix.buildMachines =
    let
      sshUser = myvars.username;
      # путь к ssh key на локальной машине
      sshKey = "/etc/agenix/ssh-key-romantic";
      systems = [
        # native arch
        "x86_64-linux"

        # эмуляция через binfmt_misc и qemu-user
        "aarch64-linux"
        "riscv64-linux"
      ];
      # system features плохо задокументированы:
      #  https://github.com/NixOS/nix/blob/e503ead/src/libstore/globals.hh#L673-L687
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
      ];
    in
    [
      # Nix часто предпочитает remote builder
      # чтобы грузить локальный CPU — не ставьте remote maxJobs слишком высоким
      # {
      #   # часть remote builders на NixOS, те же sshUser, sshKey, systems…
      #   inherit sshUser sshKey systems supportedFeatures;
      #
      #   # hostName:
      #   #   1. hostname из DNS
      #   #   2. IP remote builder
      #   #   3. alias из /etc/ssh/ssh_config
      #   hostName = "aquamarine";
      #   maxJobs = 3;
      #   # speedFactor — signed integer
      #   # https://github.com/ryan4yin/nix-config/issues/70
      #   speedFactor = 1;
      # }
      # {
      #   inherit sshUser sshKey systems supportedFeatures;
      #   hostName = "ruby";
      #   maxJobs = 2;
      #   speedFactor = 1;
      # }
      # {
      #   inherit sshUser sshKey systems supportedFeatures;
      #   hostName = "kana";
      #   maxJobs = 2;
      #   speedFactor = 1;
      # }
    ];
  # опционально, если у builder быстрее интернет
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
