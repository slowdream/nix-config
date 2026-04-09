# Disko: idols-ai, целевой диск nvme1n1 (после миграции).
# Как nvme0n1: ESP + LUKS + btrfs, эфемерный root (tmpfs).
#
# destroy, format, mount (снос диска; из nixos-installer: cd nix-config/nixos-installer):
#   nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix
# только mount:
#   nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs.nix
#
# Подмена device при установке:
#   nixos-install --flake .#ai --option disko.devices.disk.nixos-ai.device /dev/nvme1n1
{
  # эфемерный root; состояние в /persistent (preservation)
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    # tmpfs root: relatime + mode=755 (не 777 от systemd)
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "relatime" # atime относительно mtime/ctime
        "mode=755"
      ];
    };

    disk.nixos-ai = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          # ESP без шифрования — UEFI грузит bootloader
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "600M";
            type = "EF00"; # ESP в GPT
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0177" # файлы 600
                "dmask=0077" # каталоги 700
                "noexec,nosuid,nodev"
              ];
            };
          };
          # root: LUKS + btrfs subvol
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # перезаписать существующую ФС
              subvolumes = {
                # корень btrfs (id 5) — снимки / send-receive
                "/" = {
                  mountpoint = "/btr_pool";
                  mountOptions = [ "subvolid=5" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress-force=zstd:1" # сжатие на SSD
                    "noatime"
                  ];
                };
                "@guix" = {
                  mountpoint = "/gnu";
                  mountOptions = [
                    "compress-force=zstd:1"
                    "noatime"
                  ];
                };
                "@persistent" = {
                  mountpoint = "/persistent";
                  mountOptions = [
                    "compress-force=zstd:1"
                  ];
                };
                "@snapshots" = {
                  mountpoint = "/snapshots";
                  mountOptions = [
                    "compress-force=zstd:1"
                  ];
                };
                "@tmp" = {
                  mountpoint = "/tmp";
                  mountOptions = [
                    "compress-force=zstd:1"
                  ];
                };
                # swapfile в subvol; disko добавит swapDevices
                "@swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "5G";
                };
              };
            };
          };
        };
      };
    };
  };
}
