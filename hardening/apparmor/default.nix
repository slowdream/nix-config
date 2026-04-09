{
  config,
  pkgs,
  ...
}:
{
  services.dbus.apparmor = "enabled";
  security.apparmor = {
    enable = true;

    # убивать процессы без confinement, если для них есть профили AppArmor
    killUnconfinedConfinables = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];

    # политики AppArmor
    policies = {
      "default_deny" = {
        enforce = false;
        enable = false;
        profile = ''
          profile default_deny /** { }
        '';
      };

      "sudo" = {
        enforce = false;
        enable = false;
        profile = ''
          ${pkgs.sudo}/bin/sudo {
            file /** rwlkUx,
          }
        '';
      };

      "nix" = {
        enforce = false;
        enable = false;
        profile = ''
          ${config.nix.package}/bin/nix {
            unconfined,
          }
        '';
      };
    };
  };

  environment.systemPackages = with pkgs; [
    apparmor-bin-utils
    apparmor-profiles
    apparmor-parser
    libapparmor
    apparmor-kernel-patches
    apparmor-pam
    apparmor-utils
  ];
}
