{
  preservation,
  lib,
  pkgs,
  myvars,
  ...
}:
let
  inherit (myvars) username;
in
{
  imports = [
    preservation.nixosModules.default
  ];

  preservation.enable = true;
  boot.initrd.systemd.enable = true;

  environment.systemPackages = [
    # `sudo ncdu -x /`
    pkgs.ncdu
  ];

  # NOTE: `preservation` монтирует в /persistent только список ниже
  # Если каталог/файл уже есть в rootfs — сначала перенесите в /persistent!
  preservation.preserveAt."/persistent" = {
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/ssh"
      "/etc/nix/inputs"
      "/etc/secureboot" # lanzaboote / secure boot
      # секреты
      "/etc/agenix/"

      "/var/log"
      "/var/lib"

      # k3s
      "/etc/iscsi"
      "/etc/rancher"
    ];
    files = [
      # machine-id
      {
        file = "/etc/machine-id";
        inInitrd = true;
      }
    ];

    # эти каталоги → /persistent/home/$USER
    users.${username} = {
      directories = [
        "codes"
        "nix-config"
        "tmp"
      ];
    };
  };

  # Каталоги с нужными правами.
  #
  # Здесь `/home/butz/.local` не является прямым родителем сохранённого файла,
  # tmpfiles создал бы root:root 0755 — пользователь не сможет писать внутрь.
  #
  # systemd-tmpfiles задаёт владельца и mode.
  #
  # Родители сохранённых файлов можно задать через `parent` и `configureParent = true`.
  systemd.tmpfiles.settings.preservation =
    let
      permission = {
        user = username;
        group = lib.mkForce username;
        mode = lib.mkForce "0750";
      };
    in
    {
      "/home/${username}/.config".d = permission;
      "/home/${username}/.local".d = permission;
      "/home/${username}/.local/share".d = permission;
      "/home/${username}/.local/state".d = permission;
      "/home/${username}/.terraform.d".d = permission;
    };

  # systemd-machine-id-commit упадёт — для persistent machine-id не нужен, отключаем
  #
  # альтернатива — пример firstboot ниже
  systemd.suppressedSystemUnits = [ "systemd-machine-id-commit.service" ];

  # закоммитить transient ID на persistent том
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };
}
