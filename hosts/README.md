# Hosts

Эта директория содержит все host-specific конфигурации моих систем NixOS.

## Текущий список хостов

### Физические машины

#### `idols` - основные рабочие станции

Названы в честь персонажей из "Oshi no Ko":

| Host         | Platform    | Hardware              | Purpose               | Status      |
| ------------ | ----------- | --------------------- | --------------------- | ----------- |
| `ai`         | NixOS       | i5-13600KF + RTX 4090 | Gaming & Daily Use    | ✅ Active   |
| `aquamarine` | KubeVirt VM | Virtual               | Monitoring & Services | ✅ Active   |
| `kana`       | NixOS       | Virtual               | Reserved              | ⚪ Not Used |
| `ruby`       | NixOS       | Virtual               | Reserved              | ⚪ Not Used |

#### `12kingdoms` - homelab серверы

Названы в честь "Twelve Kingdoms":

| Host      | Platform | Hardware                               | Purpose                    | Status    |
| --------- | -------- | -------------------------------------- | -------------------------- | --------- |
| `shoryu`  | NixOS    | MoreFine S500Plus (AMD Ryzen 9 5900HX) | KubeVirt Host & K3s Master | ✅ Active |
| `shushou` | NixOS    | MinisForum UM560 (AMD Ryzen 5 5625U)   | KubeVirt Host & K3s Master | ✅ Active |
| `youko`   | NixOS    | MinisForum HX99G (AMD Ryzen 9 6900HX)  | KubeVirt Host & K3s Master | ✅ Active |

### Virtual Machines и clusters

#### `k8s` - Kubernetes инфраструктура

- **KubeVirt Cluster**: 3 physical mini PCs (shoryu, shushou, youko) running all VMs
- **K3s Production**: 3 masters + 3 workers for production workloads
- **K3s Testing**: 3 masters for testing and development

### Внешние системы

- **SBCs**: aarch64/riscv64 single-board computers managed in
  [ryan4yin/nixos-config-sbc](https://github.com/ryan4yin/nixos-config-sbc)

Все мои riscv64 hosts:

![](/_img/nixos-riscv-cluster.webp)

## Naming Conventions

- **idols**: персонажи из anime/manga "Oshi no Ko"
- **12kingdoms**: персонажи из anime/novel series "Twelve Kingdoms"
- **k8s**: Kubernetes-системы следуют стандартным naming patterns

## Как добавить новый host

Проще всего добавить новый host — скопировать и адаптировать уже существующую похожую конфигурацию.
Все host-конфигурации построены по похожим шаблонам, но отличаются под конкретное железо и use case.

### Общий процесс

1. **Найдите похожий существующий host** по структуре директорий выше
2. **Скопируйте директорию целиком** и переименуйте под новый host
3. **Адаптируйте конфигурационные файлы** под своё железо и требования
4. **Обновите ссылки** в flake outputs и в network-конфигурации

### Обязательные шаги

1. В `hosts/`
   1. Создайте новую папку в `hosts/` с именем нового host.
   2. Добавьте `hardware-configuration.nix` нового host в эту папку, а `configuration.nix` подключите
      в `hosts/<name>/default.nix`.
   3. Если новому host нужен home-manager — добавьте его кастомную конфигурацию в
      `home/hosts/linux/<name>.nix`.
1. В `outputs/`
   1. Добавьте новый nix-файл `outputs/<system-architecture>/src/<name>.nix`.
   2. Скопируйте содержимое из похожего существующего host и адаптируйте под новый.
      1. Обычно достаточно изменить поля `name` и `tags`.
   3. [Optional] Добавьте unit test файл в `outputs/<system-architecture>/tests/<name>.nix`, чтобы
      тестировать nix-файл нового host.
   4. [Optional] Добавьте integration test файл в
      `outputs/<system-architecture>/integration-tests/<name>.nix`, чтобы проверить, что nix config
      для host собирается и деплоится корректно.
1. В `vars/networking.nix`
   1. Добавьте static IP address нового host.
   1. Пропустите шаг, если host не в локальной сети или это мобильное устройство.

### Шаблоны файлов

Используйте существующие hosts как шаблоны. Ключевые файлы обычно такие:

- `default.nix` - основной host-конфиг
- `hardware-configuration.nix` - авто-сгенерированные hardware настройки
- platform-specific файлы (например, `nvidia.nix` и т.д.)

### Примеры для ориентира

- **Desktop systems**: см. `idols-ai/` — gaming/workstation setup
- **Server systems**: см. `kubevirt-shoryu/` — K8s/KubeVirt hosts

## Distributed Building

Обычно я запускаю build на `Ai`, а Nix распределяет сборку по другим NixOS машинам — это удобно и
быстро.

При сборке некоторых пакетов для riscv64 или aarch64 у меня часто нет доступного cache из-за разных
изменений «под капотом», поэтому приходится собирать больше пакетов, чем обычно. Это одна из причин,
почему изначально появился кластер, и ещё одна причина — distributed building просто классная штука.

![](/_img/nix-distributed-building.webp)

![](/_img/nix-distributed-building-log.webp)

## References

[Oshi no Ko 【推しの子】 - Wikipedia](https://en.wikipedia.org/wiki/Oshi_no_Ko):

![](/_img/idols-famaily.webp) ![](/_img/idols-ai.webp)

[The Rolling Girls【ローリング☆ガールズ】 - Wikipedia](https://en.wikipedia.org/wiki/The_Rolling_Girls):

![](/_img/rolling_girls.webp)

[List of Twelve Kingdoms characters](https://en.wikipedia.org/wiki/List_of_Twelve_Kingdoms_characters)

![](/_img/12kingdoms-1.webp) ![](/_img/12kingdoms-Youko-Rakushun.webp)

[List of Frieren characters](https://en.wikipedia.org/wiki/List_of_Frieren_characters)
