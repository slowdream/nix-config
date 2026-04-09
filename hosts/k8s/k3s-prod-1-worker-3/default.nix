{
  config,
  pkgs,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-prod-1-worker-3"; # имя хоста

  coreModule = mylib.genKubeVirtGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sAgentModule {
    inherit pkgs;
    tokenFile = config.age.secrets."k3s-prod-1-token".path;
    # свой домен и VIP kube-vip для API
    masterHost = "prod-cluster-1.writefor.fun";

    # k3sExtraArgs = [
    #   # приватный IPv4 CIDR (вся сеть) — 172.16.0.0/12
    #   # Pod CIDR, IPv6 (вся сеть) — fdfd:cafe:00:0000::/64 … fdfd:cafe:00:7fff::/64
    #   # Service CIDR, IPv6 (вся сеть) — fdfd:cafe:00:8000::/64 … fdfd:cafe:00:ffff::/64
    #   "--cluster-cidr=172.20.0.0/16,fdfd:cafe:00:0003::/64"
    #   "--service-cidr=172.21.0.0/16,fdfd:cafe:00:8003::/112"
    # ];
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    coreModule
    k3sModule
  ];
}
