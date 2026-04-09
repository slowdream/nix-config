{
  programs.wireshark = {
    enable = true;
    # Пользователям группы wireshark — захват трафика (setcap wrapper).
    dumpcap.enable = true;
    # Пользователям группы wireshark — захват USB (udev rules).
    usbmon.enable = false;
  };
}
