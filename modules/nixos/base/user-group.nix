{
  myvars,
  config,
  ...
}:
{
  # Не давать менять users вне конфига
  users.mutableUsers = false;

  users.groups = {
    "${myvars.username}" = { };
    podman = { };
    docker = { };
    wireshark = { };
    # udev rules android platform tools
    adbusers = { };
    dialout = { };
    # openocd (embedded development)
    plugdev = { };
    # misc
    uinput = { };
    # общая группа для сервисов с одним data directory
    # (напр. sftpgo + transmission на aquamarine)
    fileshare = { };
  };

  users.users."${myvars.username}" = {
    # при tmpfs на / нужен initialHashedPassword
    inherit (myvars) initialHashedPassword;
    home = "/home/${myvars.username}";
    isNormalUser = true;
    extraGroups = [
      myvars.username
      "users"
      "wheel"
      "networkmanager" # nmtui / nm-connection-editor
      "podman"
      "docker"
      "wireshark"
      "adbusers" # android debug
      "libvirtd" # virt-viewer / qemu
      "fileshare"
    ];
  };

  # ssh-ключи root в основном для remote deploy
  users.users.root = {
    inherit (myvars) initialHashedPassword;
    openssh.authorizedKeys.keys = myvars.mainSshAuthorizedKeys ++ myvars.secondaryAuthorizedKeys;
  };
}
