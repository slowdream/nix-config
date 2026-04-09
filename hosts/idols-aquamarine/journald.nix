{
  # journald — лимит на диске
  # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    RuntimeMaxUse=256M
  '';
}
