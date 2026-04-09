{
  fileSystems."/mnt/utm" = {
    device = "share"; # тег 9p в UTM/QEMU
    fsType = "9p";
    options = [
      "trans=virtio" # virtio 9p
      "version=9p2000.L" # протокол 9P для Linux
      "ro" # только чтение
      "_netdev" # после сети
      "nofail" # бут не ломать при ошибке mount
      "auto" # mount -a

      # владелец на стороне гостя
      "uid=1000"
      "gid=1000"
    ];
  };
}
