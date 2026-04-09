{
  config,
  myvars,
  pkgs,
  ...
}:
let
  dataDir = "/data/fileshare/public/transmission";
  name = "transmission";
in
{
  # Общая группа fileshare — transmission и sftpgo пишут в одни каталоги (setgid).
  users.users.${name}.extraGroups = [ "fileshare" ];

  # Домашний каталог transmission: setgid + группа fileshare.
  # setgid (2) — новые файлы наследуют группу fileshare, кто бы ни создал.
  systemd.tmpfiles.rules = [
    # Родитель /data/fileshare — root, иначе tmpfiles ругается на «unsafe path transition»,
    # когда другой сервис создаёт подкаталоги в /data/fileshare/public.
    "d /data/fileshare 2775 root fileshare -"

    "d ${dataDir} 2775 ${name} fileshare -"
    "d ${dataDir}/incomplete 2775 ${name} fileshare -"
    "d ${dataDir}/downloads 2775 ${name} fileshare -"
    "d ${dataDir}/watch 2775 ${name} fileshare -"
  ];

  # headless Transmission (демон без GUI)
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/torrent/transmission.nix
  # https://wiki.archlinux.org/title/transmission
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = name;
    group = name;
    # 2775: setgid сохраняет группу fileshare в download/incomplete
    downloadDirPermissions = "2775";

    # Подкрутка sysctl под много соединений; поднять и peer-limit-global.
    # Агрессивные значения — на десктопе SSH может чаще рваться.
    performanceNetParameters = true;

    # JSON с настройками вне store (секреты вроде rpc-password).
    credentialsFile = config.age.secrets."transmission-credentials.json".path;

    # RPC в firewall не открывать
    openRPCPort = false;
    openPeerPorts = true;

    # https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
    settings = {
      # 0 = None, 1 = Critical, 2 = Error, 3 = Warn, 4 = Info, 5 = Debug, 6 = Trace
      message-level = 3;

      # Шифрование — обход фильтров ISP, чуть выше CPU.
      # 0 = предпочитать открытые, 1 = предпочитать шифрование, 2 = только шифрование; по умолчанию 1
      encryption = 2;

      # rpc = веб-интерфейс
      rpc-port = 9091;
      rpc-bind-address = "127.0.0.1";
      anti-brute-force-enabled = true;
      # После стольких неудачных попыток входа RPC не принимает auth, пока сервис не перезапустят.
      # Счётчик общий, не per-IP.
      anti-brute-force-threshold = 20;
      rpc-authentication-required = true;

      # Список IP через запятую, `*` — wildcard. Пример: "127.0.0.*,192.168.*.*"
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.*,192.168.*.*";
      # Домены через запятую. Пример: "*.foo.org,example.com"
      rpc-host-whitelist-enabled = true;
      rpc-host-whitelist = "*.writefor.fun,localhost,192.168.5.*";
      rpc-user = myvars.username;
      rpc-username = myvars.username;
      # rpc-password = "test"; # лучше credentialsFile

      incomplete-dir-enabled = true;
      incomplete-dir = "${dataDir}/incomplete";
      download-dir = "${dataDir}/downloads";

      # Каталог watch: .torrent подхватываются
      watch-dir-enabled = false;
      watch-dir = "${dataDir}/watch";
      # µTP
      utp-enabled = true;
      # Скрипт по завершении торрента
      script-torrent-done-enabled = false;
      # script-torrent-done-filename = "/path/to/script";

      # LPD
      lpd-enabled = true;
      # Порт для входящих peer
      peer-port = 51413;
      # UPnP / NAT-PMP для проброса порта
      # https://github.com/transmission/transmission/blob/main/docs/Port-Forwarding-Guide.md
      port-forwarding-enabled = true;

      # лимиты скорости
      speed-limit-down-enabled = true;
      speed-limit-down = 30000; # KB/s
      speed-limit-up-enabled = true;
      speed-limit-up = 500; # KB/s
      upload-slots-per-torrent = 8;

      # стартовать торренты сразу после добавления
      start-added-torrents = true;

      # очередь
      # true — качает не больше download-queue-size не-stalled торрентов
      download-queue-enabled = true;
      download-queue-size = 5;

      # true — торренты без отдачи дольше queue-stalled-minutes считаются stalled
      # и не учитываются в лимитах download/seed queue
      queue-stalled-enabled = true;
      queue-stalled-minutes = 60;

      # true — одновременно не больше seed-queue-size не-stalled сидов
      seed-queue-enabled = true;
      seed-queue-size = 10;
    };
  };
}
