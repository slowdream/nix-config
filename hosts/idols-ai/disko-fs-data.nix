# Второй диск idols-ai: LUKS + btrfs → /persistent/data (см. фактический mount в конфиге).
#
# destroy, format, mount:
#   nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs-data.nix
# только mount:
#   nix run github:nix-community/disko -- --mode mount ../hosts/idols-ai/disko-fs-data.nix
#
{
  disko.devices = {
    disk.data = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-Fanxiang_S790_2TB_FXS790254050582";
      content = {
        type = "gpt";
        partitions = {
          datapart = {
            size = "100%";
            content = {
              type = "luks";
              name = "data-luks"; # mapper = boot.initrd.luks
              settings = {
                allowDiscards = true; # TRIM
              };
              # пароль в initrd
              initrdUnlock = true;
              # cryptsetup luksFormat
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--iter-time 5000"
                "--key-size 256"
                "--pbkdf argon2id"
                "--use-random" # /dev/random
              ];
              extraOpenArgs = [
                "--timeout 10"
              ];
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # перезапись ФС
                subvolumes = {
                  "@data" = {
                    mountpoint = "/data";
                    mountOptions = [
                      "compress-force=zstd:1"
                    ];
                  };
                };
                postMountHook = ''
                  chown ryan:users /mnt/data
                  # SGID 2755 — новые файлы с группой каталога
                  chmod 2755 /mnt/data
                '';
              };
            };
          };
        };
      };
    };
  };
}
