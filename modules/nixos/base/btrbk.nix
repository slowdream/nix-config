{
  # ==================================================================
  #
  # Снимки и remote backup subvolumes btrfs
  #   https://github.com/digint/btrbk
  #
  # Использование:
  #   1. btrbk по расписанию создаёт snapshots
  #   2. вручную: команда `btrbk run`
  #
  # Восстановление snapshot:
  #   1. Нужный snapshot в /snapshots
  #   2. `btrfs subvol delete /btr_pool/@persistent` — удалить текущий subvolume
  #   3. `btrfs subvol snapshot /snapshots/2021-01-01 /btr_pool/@persistent`
  #   4. reboot или remount, чтобы увидеть изменения
  #
  # ==================================================================

  services.btrbk.instances.btrbk = {
    # Период запуска instance. Формат: systemd.time(7)
    onCalendar = "Tue,Sat *-*-* 3:45:20";
    settings = {
      # prune локальных snapshots:
      # 1. daily на xx дней
      snapshot_preserve = "7d";
      # 2. все snapshots 2 дня, как часто ни запускай btrbk/cron
      snapshot_preserve_min = "2d";

      # prune remote incremental backups:
      # daily 9d, weekly 4w, monthly 2m
      target_preserve = "9d 4w 2m";
      target_preserve_min = "no";

      volume = {
        "/btr_pool" = {
          subvolume = {
            "@persistent" = {
              snapshot_create = "always";
            };
          };

          # backup на remote или в локальную директорию
          # prune: `target_preserve` и `target_preserve_min`
          # target = "/snapshots";
        };
      };
    };
  };
}
