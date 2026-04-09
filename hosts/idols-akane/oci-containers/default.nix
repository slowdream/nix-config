{
  mylib,
  lib,
  pkgs,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  # environment.systemPackages = with pkgs; [
  #   podman-compose
  # ];

  virtualisation = {
    docker.enable = true;
    # podman = {
    #   enable = true;
    #   # алиас `docker` → podman
    #   dockerCompat = true;
    #   # DNS между контейнерами podman-compose
    #   defaultNetwork.settings.dns_enabled = true;
    #   # автоочистка Podman
    #   autoPrune = {
    #     enable = true;
    #     dates = "weekly";
    #     flags = [ "--all" ];
    #   };
    # };

    oci-containers = {
      backend = "docker";
    };
  };
}
