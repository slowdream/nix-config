{
  # нужно для preservation
  fileSystems."/persistent".neededForBoot = true;

  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=4G"
        "defaults"
        # mode 755, иначе systemd даст 777
        # relatime: atime относительно mtime/ctime
        "mode=755"
      ];
    };

    disk.main = {
      type = "disk";
      # при disko-install подменяется с CLI
      device = "/dev/nvme0n1"; # диск для разметки
      content = {
        type = "gpt";
        partitions = {
          # EFI / boot
          ESP = {
            size = "630M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "fmask=0177" # файлы: 600
                "dmask=0077" # каталоги: 700
                "noexec,nosuid,nodev" # без exec/setuid/device nodes
              ];
            };
          };
          # корень (LUKS)
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "encrypted";
              settings = {
                # fallbackToPassword = true;
                allowDiscards = true;
              };
              # boot.initrd.luks.devices для этого диска
              initrdUnlock = true;

              # корень: LUKS2 + argon2id, пароль при unlock
              # cryptsetup luksFormat
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                # энтропия из /dev/random (может подождать)
                "--use-random"
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # перезаписать существующий раздел
                subvolumes = {
                  # корневой subvol → /btr_pool (снимки btrbk)
                  "/" = {
                    mountpoint = "/btr_pool";
                    # корень btrfs, id 5
                    # отсюда видны остальные subvol
                    mountOptions = [ "subvolid=5" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@tmp" = {
                    mountpoint = "/tmp";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/snapshots";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16384M";
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
