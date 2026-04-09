## Как создать и управлять Virtual Machine в KubeVirt из этого flake?

Возьмём `aquamarine` как пример. Сначала соберите и загрузите qcow2-образ виртуальной машины на fileserver:

```shell
just upload-vm aquamarine
```

Затем создайте виртуальную машину: добавьте yaml-файл в
[ryan4yin/k8s-gitops](https://github.com/ryan4yin/k8s-gitops/tree/main/vms), укажите
`spec.dataVolumeTemplates[0].source.http.url` на URL загруженного файла — и fluxcd автоматически
применит изменения. После этого в кластере KubeVirt появится virtual machine с именем `aquamarine`.

Когда virtual machine `aquamarine` создана, обновления можно деплоить так:

```shell
just col aquamarine
just col kubevirt-shoryu
just col k3s-test-1-master-1
```

Если вы не знакомы с remote deployment, сначала прочитайте:
[Remote Deployment - NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/best-practices/remote-deployment)
