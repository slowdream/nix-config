{
  pkgs,
  # nur-ataraxiasjel,
  ...
}:
{
  ###################################################################################
  #
  #  Virtualisation — Libvirt (QEMU/KVM) / Docker / LXD / WayDroid
  #
  ###################################################################################

  # Включить nested virtualization (нужно для security containers и nested VM).
  # Задаётся per-host в /hosts, не здесь.
  #
  ## AMD CPU: добавить "kvm-amd" в kernelModules.
  # boot.kernelModules = ["kvm-amd"];
  # boot.extraModprobeConfig = "options kvm_amd nested=1";  # amd cpu
  #
  ## Intel CPU: добавить "kvm-intel" в kernelModules.
  # boot.kernelModules = ["kvm-intel"];
  # boot.extraModprobeConfig = "options kvm_intel nested=1"; # intel cpu

  boot.kernelModules = [ "vfio-pci" ];

  services.flatpak.enable = true;

  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      # Алиас `docker` для podman как drop-in replacement
      dockerCompat = true;
      # Нужно, чтобы контейнеры под podman-compose могли общаться друг с другом.
      defaultNetwork.settings.dns_enabled = true;
      # Периодическая очистка ресурсов Podman
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    oci-containers = {
      backend = "podman";
    };

    # Использование: https://wiki.nixos.org/wiki/Waydroid
    # waydroid.enable = true;

    # libvirtd = {
    #   enable = true;
    #   # Смена этой опции на false может сломать права на файлы у существующих guests.
    #   # Починка: вручную сменить владельца в /var/lib/libvirt/qemu на qemu-libvirtd.
    #   qemu.runAsRoot = true;
    # };

    # lxd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Скрипт для установки ARM translation layer в waydroid,
    # чтобы ставить arm apk на x86_64 waydroid
    #
    # https://github.com/casualsnek/waydroid_script
    # https://github.com/AtaraxiaSjel/nur/tree/master/pkgs/waydroid-script
    # https://wiki.archlinux.org/title/Waydroid#ARM_Apps_Incompatible
    # nur-ataraxiasjel.packages.${pkgs.stdenv.hostPlatform.system}.waydroid-script

    # При первом запуске: [File (меню) -> Add connection]
    # virt-manager

    # QEMU/KVM (HostCpuOnly), даёт:
    #   qemu-storage-daemon qemu-edid qemu-ga
    #   qemu-pr-helper qemu-nbd elf2dmp qemu-img qemu-io
    #   qemu-kvm qemu-system-x86_64 qemu-system-aarch64 qemu-system-i386
    qemu_kvm

    # QEMU (другие архитектуры), даёт:
    #   ......
    #   qemu-loongarch64 qemu-system-loongarch64
    #   qemu-riscv64 qemu-system-riscv64 qemu-riscv32  qemu-system-riscv32
    #   qemu-system-arm qemu-arm qemu-armeb qemu-system-aarch64 qemu-aarch64 qemu-aarch64_be
    #   qemu-system-xtensa qemu-xtensa qemu-system-xtensaeb qemu-xtensaeb
    #   ......
    qemu
  ];
}
