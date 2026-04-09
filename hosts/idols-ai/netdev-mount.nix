{
  config,
  ...
}:
{
  # davfs2 для WebDAV
  services.davfs2 = {
    enable = true;
    # https://man.archlinux.org/man/davfs2.conf.5
    settings = {
      globalSection.use_locks = true;
      sections = {
        "/mnt/fileshare" = {
          # один PROPFIND на каталог вместо запросов по каждому файлу
          gui_optimize = true;
        };
      };
    };
  };

  # WebDAV
  # https://wiki.archlinux.org/title/Davfs2
  fileSystems."/mnt/fileshare" = {
    device = "https://webdav.writefor.fun/";
    fsType = "davfs";
    options = [
      # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
      "nofail"
      "_netdev" # после сети
      "rw"
      "uid=1000,gid=100,dir_mode=0750,file_mode=0750"
    ];
  };
  # учётные данные в /etc/davfs2/secrets
  environment.etc."davfs2/secrets" = {
    source = config.age.secrets."davfs-secrets".path;
    mode = "0600";
  };
}
