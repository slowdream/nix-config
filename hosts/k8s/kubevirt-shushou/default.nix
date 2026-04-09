{
  config,
  pkgs,
  mylib,
  myvars,
  disko,
  ...
}:
let
  hostName = "kubevirt-shushou"; # имя хоста

  coreModule = mylib.genKubeVirtHostModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
  };
  k3sModule = mylib.genK3sServerModule {
    inherit pkgs;
    kubeconfigFile = "/home/${myvars.username}/.kube/config";
    tokenFile = "/persistent/kubevirt-k3s-token";
    # свой домен и VIP kube-vip для API
    masterHost = "kubevirt-cluster-1.writefor.fun";
    kubeletExtraArgs = [
      "--cpu-manager-policy=static"
      # https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/
      # резерв под системные pod'ы и systemd при static cpu-manager
      # плюс память ядра — не в accounting pod'ов
      "--system-reserved=cpu=1,memory=2Gi,ephemeral-storage=2Gi"
    ];
    k3sExtraArgs = [
      # приватный IPv4 CIDR (вся сеть) — 172.16.0.0/12
      # Pod CIDR, IPv6 (вся сеть) — fdfd:cafe:00:0000::/64 … fdfd:cafe:00:7fff::/64
      # Service CIDR, IPv6 (вся сеть) — fdfd:cafe:00:8000::/64 … fdfd:cafe:00:ffff::/64
      # "--cluster-cidr=172.16.0.0/16,fdfd:cafe:00:0001::/64"
      # "--service-cidr=172.17.0.0/16,fdfd:cafe:00:8001::/112"
    ];
    nodeLabels = [
      "node-purpose=kubevirt"
    ];
    disableFlannel = false;
  };
in
{
  imports = (mylib.scanPaths ./.) ++ [
    disko.nixosModules.default
    ../disko-config/kubevirt-disko-fs.nix
    ../kubevirt-shoryu/hardware-configuration.nix
    ../kubevirt-shoryu/preservation.nix
    coreModule
    k3sModule
  ];

  boot.kernelParams = [
    # transparent hugepages выключены
    "transparent_hugepage=never"

    # https://kubevirt.io/user-guide/compute/hugepages/
    #
    # hugepages вручную под гостей kubevirt
    # NOTE: только под hugepages
    # оставить память хосту и VM без hugepages
    "hugepagesz=1G"
    "hugepages=48" # ~75% RAM под hugepages
  ];
}
