# Kubernetes Clusters

> WIP, ещё не закончено.

У меня запущены два Kubernetes cluster: один для production, второй для testing.

В качестве Kubernetes distribution я предпочитаю [k3s], потому что он лёгкий, простой в установке и
достаточно full featured (подробности см. в [what-have-k3s-removed-from-upstream-kubernetes]).

## KubeVirt Cluster

KubeVirt cluster работает на физических машинах. Все мои virtual machines запускаются в этом
кластере, включая другие Kubernetes clusters.

![](../../_img/2024-04-02_kubevirt-cluster-nodes.webp)
![](../../_img/2024-04-02_kubevirt-cluster-pods.webp)

## K3s Clusters

Clusters, которые работают как virtual machines внутри KubeVirt cluster, для testing и production.

![](/_img/2024-02-18_k8s-nodes-overview.webp)

1. Для production:
   1. `k3s-prod-1-master-1`
   1. `k3s-prod-1-master-2`
   1. `k3s-prod-1-master-3`
   1. `k3s-prod-1-worker-1`
   1. `k3s-prod-1-worker-2`
   1. `k3s-prod-1-worker-3`
1. Для testing:
   1. `k3s-test-1-master-1`
   2. `k3s-test-1-master-2`
   3. `k3s-test-1-master-3`

## Kubernetes Resources

Kubernetes resources деплоятся и управляются отдельно через
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops).

[k3s]: https://github.com/k3s-io/k3s/
[what-have-k3s-removed-from-upstream-kubernetes]:
  https://github.com/k3s-io/k3s/?tab=readme-ov-file#what-have-you-removed-from-upstream-kubernetes
