# Разметка диска (из корня репо nix-config):
#   nix run github:nix-community/disko -- --mode destroy,format,mount hosts/idols-aquamarine/disko-fs.nix
# Только mount (после первого format):
#   nix run github:nix-community/disko -- --mode mount hosts/idols-aquamarine/disko-fs.nix
let
  cryptKeyFile = "/etc/agenix/hdd-luks-crypt-key";
  unlockDisk = "data-encrypted";
in
{
  # /data-ro bind на /data только чтение.
  # Отдельный source вместо self-bind — без дубликатов в lsblk.
  # Subvol (@apps, @fileshare, …) монтируются поверх; при ошибке (nofail)
  # виден RO-слой — запись в подкаталог даст EROFS.
  fileSystems."/data" = {
    device = "/data-ro";
    fsType = "none";
    options = [
      "bind"
      "ro"
    ];
  };

  # Каталоги под subvol до mount; activation до sysinit — пишем в /data-ro, не в ro /data.
  system.activationScripts.data-ro-backing.text = ''
    mkdir -p /data-ro/fileshare /data-ro/apps /data-ro/backups /data-ro/apps-snapshots
  '';

  fileSystems."/data/fileshare/public".depends = [ "/data/fileshare" ];

  # crypttab → systemd-cryptsetup@ при загрузке; после agenix, keyfile на месте.
  environment.etc = {
    "crypttab".text = ''
      ${unlockDisk} /dev/disk/by-partlabel/disk-${unlockDisk}-luks ${cryptKeyFile} luks,discard,keyfile-size=32768,keyfile-offset=65536
    '';
  };

  disko.devices = {
    disk.data-encrypted = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EZRZ-22GXCB0_WD-WCC7K7VV9613";
      content = {
        type = "gpt";
        partitions = {
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "data-encrypted";
              settings = {
                keyFile = cryptKeyFile;
                # keyfile до 8192 KiB — см. cryptsetup --help
                # пример: dd bs=512 count=1024 iflag=fullblock if=/dev/random of=./hdd-luks-crypt-key
                keyFileSize = 512 * 64; # как bs*count в dd
                keyFileOffset = 512 * 128; # как bs*skip в dd
                fallbackToPassword = true;
                allowDiscards = true;
              };
              # initrd unlock выкл.: keyfile появляется только после agenix
              initrdUnlock = false;

              # LUKS2 + argon2id; пароль при luksFormat
              # cryptsetup luksFormat
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                # /dev/random — ждёт энтропию
                "--use-random"
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # перезаписать раздел
                subvolumes = {
                  "@apps" = {
                    mountpoint = "/data/apps";
                    mountOptions = [
                      "compress-force=zstd:1"
                      # https://www.freedesktop.org/software/systemd/man/latest/systemd.mount.html
                      "nofail"
                    ];
                  };
                  "@fileshare" = {
                    mountpoint = "/data/fileshare";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                  "@backups" = {
                    mountpoint = "/data/backups";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/data/apps-snapshots";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "nofail"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
    disk.data-public = {
      type = "disk";
      device = "/dev/disk/by-id/ata-WDC_WD40EJRX-89T1XY0_WD-WCC7K0XDCZE6";
      content = {
        type = "gpt";
        partitions.data-fileshare = {
          size = "100%";
          content = {
            type = "btrfs";
            # extraArgs = ["-f"]; # перезаписать раздел
            subvolumes = {
              "@persistent" = {
                mountpoint = "/data/fileshare/public";
                mountOptions = [
                  "compress-force=zstd:1"
                  "nofail"
                ];
              };
            };
          };
        };
      };
    };
  };
}
