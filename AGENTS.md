# AGENTS.md — правила для AI Coding Agents

Этот файл задаёт базовые правила работы AI agents в этом репозитории Nix Flake.
Изменения должны быть минимальными, проверяемыми и безопасными для multi-host деплоев.

## Область применения и модель репозитория

Этот репозиторий управляет:

- NixOS hosts (desktop + servers)
- Home Manager profiles
- Remote deployments via colmena

Общая структура:

```text
.
├── flake.nix                    # Flake entry; outputs composed in ./outputs
├── Justfile                     # Primary command entrypoint (uses nushell)
├── outputs/
│   ├── default.nix
│   ├── x86_64-linux/
│   ├── aarch64-linux/
├── modules/                     # NixOS modules
├── home/                        # Home Manager modules
├── hosts/                       # Host-specific config
├── vars/                        # Shared variables
├── lib/                         # Helper functions
├── agents/                      # Reusable cross-project agent files and installer
└── secrets/                     # Agenix secret definitions
```

## Базовые правила

- Предпочитайте задачи `just` вместо ad-hoc команд, если есть эквивалентная задача.
- Делайте минимально разумное изменение; избегайте drive-by refactors.
- Не коммитьте секреты, сгенерированные учётные данные или private keys.
- Сохраняйте platform guards (`[linux]`, `[macos]`) и соглашения по именованию хостов.
- Перед завершением прогоняйте форматирование и evaluation checks для затронутых частей.

## Быстрый старт (рекомендуемый workflow)

1. Посмотреть контекст:

```bash
just --list
rg -n "<symbol-or-option>" modules home hosts outputs
```

2. Внести изменения.
3. Отформатировать:

```bash
just fmt
```

4. Провалидировать:

```bash
just test
```

5. Если поведение деплоя изменилось, укажите точную команду `just`, которую должен запустить
   пользователь (не запускайте remote deploy без явного запроса).

## Канонические команды

### Основной цикл качества

```bash
just fmt                    # format Nix files
just test                   # run eval tests: nix eval .#evalTests ...
nix flake check             # run flake checks + pre-commit style checks
```

### Обновление inputs/зависимостей

```bash
just up                     # update all inputs and commit lock file
just upp <input>            # update one input and commit lock file
just up-nix                 # update nixpkgs-related inputs
```

### Локальный деплой

```bash
just local                  # deploy config for current hostname
just local debug            # same with verbose/debug mode
just niri                   # deploy "<hostname>-niri" on Linux
just niri debug             # debug mode
```

### Remote deploy (colmena)

```bash
just col <tag>              # deploy nodes matching tag
just lab                    # deploy all kubevirt nodes
just k3s-prod               # deploy k3s production nodes
just k3s-test               # deploy k3s test nodes
```

### Полезные прямые команды

```bash
nix eval .#evalTests --show-trace --print-build-logs --verbose
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
nixos-rebuild switch --flake .#<hostname>
```

## Тесты: структура и ожидания

Eval tests находятся тут:

- `outputs/x86_64-linux/tests/`
- `outputs/aarch64-linux/tests/`

Обычно тест состоит из пары:

- `expr.nix`
- `expected.nix`

Ожидания от агента:

- Если изменения логики затронули shared modules — запускайте `just test`.
- Если менялись только docs/comments — тесты можно пропустить, но скажите об этом явно.
- Если тесты нельзя запустить — объясните почему и приведите точную команду, которая падает.

## Форматирование и стиль

### Инструменты форматирования

- Nix: `nixfmt` (RFC style, width 100)
- Non-Nix: `prettier` (см. `.prettierrc.yaml`)
- Spelling: `typos` (см. `.typos.toml`)

### Nix style conventions

- Файлы используют `kebab-case.nix`.
- Для импортов атрибутов предпочитайте `inherit (...)`.
- Для условной конфигурации предпочитайте `lib.mkIf`, `lib.optional`, `lib.optionals`.
- Для значений по умолчанию используйте `lib.mkDefault`, а `lib.mkForce` — только при необходимости.
- Держите options модулей документированными через `description`.

Шаблон модуля:

```nix
{ lib, config, ... }:
{
  options.myFeature = {
    enable = lib.mkEnableOption "my feature";
  };

  config = lib.mkIf config.myFeature.enable {
    # ...
  };
}
```

## Заметки по платформам

- `Justfile` использует `nu` (`set shell := ["nu", "-c"]`).
- Некоторые задачи существуют только на Linux и помечены `[linux]` guards.

## Secrets и безопасность

- Secrets управляются через agenix и внешний приватный репозиторий секретов.
- Никогда не вставляйте значения секретов напрямую в Nix files, tests или docs.
- Не запускайте «широкие» remote deploy команды без запроса.
- Предпочитайте сначала build/eval validation, а уже потом deploy.

## Чеклист перед завершением (для агентов)

Перед завершением проверьте:

1. Изменения соответствуют запрошенному поведению.
2. Применён `just fmt` (или он не нужен — и это явно сказано).
3. Запущен `just test` для изменений конфигурации (или объяснено ограничение).
4. Не добавлены secrets или machine-specific артефакты.
5. В summary для пользователя указано, что изменилось и что было проверено.

## Частые ошибки

- Править host-specific файлы, когда изменение должно быть в shared слоях (`modules/` или `home/`).
- Забывать обновлять platform-specific пути при изменениях в shared abstractions.
- Запускать deployment-команды для проверки синтаксиса, когда безопаснее `nix eval`/`nix build`.
- Вносить захардкоженные usernames/paths вместо использования `myvars` и существующих абстракций.

## Ссылки

- [README.md](./README.md)
- [agents/README.md](./agents/README.md)
- [Justfile](./Justfile)
- [outputs/README.md](./outputs/README.md)
- [hosts/README.md](./hosts/README.md)
- [home/README.md](./home/README.md)
- [modules/README.md](./modules/README.md)
- [secrets/README.md](./secrets/README.md)
