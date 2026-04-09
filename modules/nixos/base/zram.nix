{ lib, ... }:
{
  # Сжатые in-memory устройства и swap через zram.
  # Больше данных держим в RAM, меньше сразу уходим на disk-based swap —
  # лучше I/O при достаточной памяти.
  #
  #   https://www.kernel.org/doc/Documentation/blockdev/zram.txt
  zramSwap = {
    enable = true;
    # один из "lzo", "lz4", "zstd"
    algorithm = lib.mkDefault "zstd";
    # Приоритет zram swap.
    # Выше, чем у swap на диске — сначала заполняется zram, потом disk swap.
    priority = lib.mkDefault 100;
    # Максимум данных в zram swap (% от RAM).
    # По умолчанию половина RAM. Смотреть сжатие: zramctl.
    # Не то же самое, что объём RAM, занятый zram-драйвером.
    memoryPercent = lib.mkDefault 50;
  };

  # Подстройка swap на zram
  boot.kernel.sysctl = {
    # vm.swappiness — склонность к swap (0–200, default 60)
    # Для zram/zswap часто берут > 100.
    "vm.swappiness" = lib.mkDefault 180;

    # vm.watermark_boost_factor — агрессия reclaim (default 15000)
    # 0 отключает watermark boost — меньше преждевременного reclaim.
    "vm.watermark_boost_factor" = lib.mkDefault 0;

    # vm.watermark_scale_factor — как рано просыпается kswapd (1–1000, default 10)
    # Выше — фоновый reclaim раньше (~12.5% memory pressure).
    # 125: kswapd при free < 1/125 RAM — плавнее баланс при высоком swappiness.
    "vm.watermark_scale_factor" = lib.mkDefault 125;

    # vm.page-cluster — readahead при swap (0–6, default 3)
    # 0: по одной странице; для zram readahead часто вредит latency.
    "vm.page-cluster" = lib.mkDefault 0;
  };
}
