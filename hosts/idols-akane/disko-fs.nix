{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda"; # виртуальный диск
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "450M";
              type = "EF00";
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
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # перезаписать раздел
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountOptions = [ "compress=zstd:1" ];
                    mountpoint = "/home";
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "4096M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
