{
  # node exporter на всех nixos hosts
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/monitoring/prometheus/exporters/node.nix
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9100;
    # По умолчанию уже много collectors
    # https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default
    enabledCollectors = [
      "systemd"
      "logind"
    ];

    # либо enabledCollectors, либо disabledCollectors
    # disabledCollectors = [];

    extraFlags = [
      # Исключить pseudo/ephemeral FS:
      #   - /proc, /sys: kernel pseudo-FS
      #   - /dev: tmpfs/devices
      # Runtime tmp:
      #   - /run/credentials/... — secrets сервисов systemd
      #   - /run/user/... — per-user tmpfs
      # Container mounts:
      #   - /var/lib/docker/, /var/lib/containers/, /var/lib/kubelet/ — много overlay, EACCES, ложные алерты
      # User bind mounts:
      #   - /home/ryan/.+ — bind с /persistent (tmpfs root), достаточно мониторить /persistent
      # Префикс ^(/|/persistent/) — и корень, и пути под /persistent (tmpfs-as-root).
      "--collector.filesystem.mount-points-exclude=^(/|/persistent/)(dev|proc|sys|run/credentials/.+|run/user/.+|var/lib/docker/.+|var/lib/containers/.+|var/lib/kubelet/.+|home/ryan/.+)($|/)"
    ];
  };
}
