{ pkgs, ... }:
let
  passwordFile = "/etc/agenix/restic-password";
  sshKeyPath = "/etc/agenix/ssh-key-for-restic-backup";
  rcloneConfigFile = "/etc/agenix/rclone-conf-for-restic-backup";
in
{
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/backup/restic.nix
  services.restic.backups = {
    homelab-backup = {
      inherit passwordFile;
      initialize = true; # создать repo, если нет
      repository = "rclone:smb-downloads:/Downloads/kubevirt-backup/"; # удалённое хранилище через rclone remote

      # rclone
      # rcloneOptions = {
      #   bwlimit = "100M";  # лимит скорости rclone
      # };
      inherit rcloneConfigFile;

      # Локальные пути плюс `dynamicFilesFrom`
      paths = [
        "/tmp/restic-backup-temp"
      ];
      #
      # Скрипт → список файлов для `--files-from`, объединяется с `paths`
      # dynamicFilesFrom = "find /home/matt/git -type d -name .git";
      #
      # Исключения: https://restic.readthedocs.io/en/latest/040_backup.html#excluding-files
      exclude = [ ];

      # Перед backup
      backupPrepareCommand = ''
        ${pkgs.nushell}/bin/nu -c '
          let kubevirt_nodes = [
            "kubevirt-shoryu"
            "kubevirt-shushou"
            "kubevirt-youko"
          ]

          kubevirt_nodes | each {|it|
            rsync -avz \
            -e "ssh -i ${sshKeyPath}"  \
            $"($it):/perissitent/" $"/tmp/restic-backup-temp/($it)"
          }
        '
      '';
      # После backup
      backupCleanupCommand = "rm -rf /tmp/restic-backup-temp";

      # restic --option
      # extraOptions = [];

      # extraBackupArgs = [
      #   "--exclude-file=/etc/restic/excludes-list"
      # ];

      # repository = "/mnt/backup-hdd"; # локальный каталог
      # Расписание: systemd.timer(5)
      timerConfig = {
        OnCalendar = "01:30";
        RandomizedDelaySec = "1h";
      };
      # Опции для `restic forget --prune` после backup
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 3"
        "--keep-monthly 3"
        "--keep-yearly 3"
      ];
    };
  };
}
