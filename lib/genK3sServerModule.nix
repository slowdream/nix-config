{
  pkgs,
  kubeconfigFile,
  tokenFile,
  # Инициализация HA-кластера с встроенным etcd.
  # При HA с embedded etcd первый server должен иметь `clusterInit = true`,
  # остальные подключаются через `serverAddr`.
  #
  # Здесь может быть доменное имя или IP (например, virtual IP kube-vip)
  masterHost,
  clusterInit ? false,
  kubeletExtraArgs ? [ ],
  k3sExtraArgs ? [ ],
  nodeLabels ? [ ],
  nodeTaints ? [ ],
  disableFlannel ? true,
  ...
}:
let
  lib = pkgs.lib;
  package = pkgs.k3s;
in
{
  environment.systemPackages = with pkgs; [
    package
    k9s
    kubectl
    istioctl
    kubernetes-helm
    cilium-cli
    fluxcd
    clusterctl # для kubernetes cluster-api

    skopeo # копирование/синхронизация образов между registry и локальным хранилищем
    go-containerregistry # даёт `crane` и `gcrane`, по смыслу похоже на skopeo
    dive # просмотр слоёв docker-образов
  ];

  # Модули ядра, нужные для Cilium
  boot.kernelModules = [
    "ip6_tables"
    "ip6table_mangle"
    "ip6table_raw"
    "ip6table_filter"
  ];
  networking.enableIPv6 = true;
  networking.nat = {
    enable = true;
    enableIPv6 = true;
  };
  services.k3s = {
    enable = true;
    inherit package tokenFile clusterInit;
    serverAddr = if clusterInit then "" else "https://${masterHost}:6443";

    role = "server";
    # https://docs.k3s.io/cli/server
    extraFlags =
      let
        flagList = [
          "--write-kubeconfig=${kubeconfigFile}"
          "--write-kubeconfig-mode=644"
          "--service-node-port-range=80-32767"
          "--kube-apiserver-arg='--allow-privileged=true'" # нужно для kubevirt
          "--data-dir /var/lib/rancher/k3s"
          "--etcd-expose-metrics=true"
          "--etcd-snapshot-schedule-cron='0 */12 * * *'"
          # отключаем ненужные фичи
          "--disable-helm-controller" # вместо этого fluxcd
          "--disable=traefik" # ставим свой ingress controller
          "--disable=servicelb" # вместо этого kube-vip
          "--disable-network-policy"
          "--tls-san=${masterHost}"
        ]
        ++ (map (label: "--node-label=${label}") nodeLabels)
        ++ (map (taint: "--node-taint=${taint}") nodeTaints)
        ++ (map (arg: "--kubelet-arg=${arg}") kubeletExtraArgs)
        ++ (lib.optionals disableFlannel [ "--flannel-backend=none" ])
        ++ k3sExtraArgs;
      in
      lib.concatStringsSep " " flagList;
  };

  # Симлинки: каталог CNI k3s → тот же путь, что используют большинство CNI-плагинов
  # (multus, calico и т.д.)
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    # https://docs.k3s.io/networking/multus-ipams
    "L+ /opt/cni/bin - - - - /var/lib/rancher/k3s/data/cni/"
    # Если flannel отключён, каталог создаём правилом tmpfiles
    "d /var/lib/rancher/k3s/agent/etc/cni/net.d 0751 root root - -"
    # Симлинк на каталог конфигов CNI
    "L+ /etc/cni/net.d - - - - /var/lib/rancher/k3s/agent/etc/cni/net.d"
  ];
}
