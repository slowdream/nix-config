{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-test-1-master-3"; # имя хоста

  coreModule = mylib.genKubeVirtGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = config.age.secrets."k3s-test-1-token".path;
    # свой домен и VIP kube-vip для API
    masterHost = "test-cluster-1.writefor.fun";

    # k3sExtraArgs = [
    #   # приватный IPv4 CIDR (вся сеть) — 172.16.0.0/12
    #   # Pod CIDR, IPv6 (вся сеть) — fdfd:cafe:00:0000::/64 … fdfd:cafe:00:7fff::/64
    #   # Service CIDR, IPv6 (вся сеть) — fdfd:cafe:00:8000::/64 … fdfd:cafe:00:ffff::/64
    #   "--cluster-cidr=172.18.0.0/16,fdfd:cafe:00:0002::/64"
    #   "--service-cidr=172.19.0.0/16,fdfd:cafe:00:8002::/112"
    # ];
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    coreModule
    k3sModule
  ];
}
