{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
  ];

  # отключить coredump — иначе их можно эксплуатировать позже,
  # плюс система тормозит при падении процессов
  systemd.coredump.enable = false;
}
