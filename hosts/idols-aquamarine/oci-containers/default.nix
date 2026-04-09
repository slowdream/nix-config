{
  lib,
  mylib,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  virtualisation = {
    docker.enable = lib.mkForce false;
    podman = {
      enable = true;
      # алиас `docker` → podman
      dockerCompat = true;
      # DNS для контейнеров podman-compose
      defaultNetwork.settings.dns_enabled = true;
      # автоочистка Podman
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    oci-containers = {
      backend = "podman";
    };
  };
}
