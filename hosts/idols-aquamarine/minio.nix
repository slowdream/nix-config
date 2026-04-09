{ config, ... }:
let
  dataDir = [ "/data/apps/minio/data" ];
  configDir = "/data/apps/minio/config";
in
{
  # https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/services/web-servers/minio.nix
  services.minio = {
    enable = true;
    browser = true; # веб-консоль MinIO

    inherit dataDir configDir;
    listenAddress = "127.0.0.1:9096";
    consoleAddress = "127.0.0.1:9097"; # Web UI
    region = "us-east-1"; # как у AWS S3 по умолчанию

    # Файл: MINIO_ROOT_USER (по умолчанию minioadmin), MINIO_ROOT_PASSWORD (≥8 символов)
    rootCredentialsFile = config.age.secrets."minio.env".path;
  };
}
