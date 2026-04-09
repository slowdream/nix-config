{
  pkgs,
  pkgs-2505,
  nur-ryan4yin,
  ...
}:
{
  home.packages = with pkgs; [
    podman-compose
    dive # слои образа Docker
    lazydocker # Docker TUI
    skopeo # копирование/синхронизация образов между registry и локально
    go-containerregistry # `crane` и `gcrane`, по смыслу как skopeo

    kubectl
    kubectx # kubectx и kubens
    kubie # как kubectl-ctx, но per-shell (kubeconfig не трогает глобально).
    kubectl-view-secret # kubectl view-secret
    kubectl-tree # kubectl tree
    kubectl-node-shell # exec на ноду
    kubepug # проверка перед апгрейдом kubernetes
    kubectl-cnpg # CLI cloudnative-pg

    kubebuilder
    istioctl
    clusterctl # kubernetes cluster-api
    kubevirt # virtctl
    pkgs-2505.kubernetes-helm
    fluxcd
    # argocd

    ko # сборка Go-проекта в образ
  ];

  programs.k9s.enable = true;
  catppuccin.k9s.transparent = true;

  programs.kubecolor = {
    enable = true;
    enableAlias = true;
  };
}
