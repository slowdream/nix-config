{
  modulesPath,
  lib,
  ...
}:
##############################################################################
#
#  Шаблон VM под KubeVirt, в основном по:
#    https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/kubevirt.nix
#
#  Свой hardware-configuration.nix — проще кастомизировать.
#
#  URL выше использует `nixos-generator` для qcow2 под KubeVirt.
#
##############################################################################
{
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    # бэкапы внутри VM не нужны
    services.btrbk.instances = lib.mkForce { };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";

    services.qemuGuest.enable = true; # qemu-guest-agent
    services.openssh.enable = true;
    # хост настраиваем через nixos — cloud-init не нужен
    services.cloud-init.enable = lib.mkForce false;
    systemd.services."serial-getty@ttyS0".enable = true;
  };
}
