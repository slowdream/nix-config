# Flake Outputs

## Нужна ли такая сложная и детализированная структура?

Если у вас немного машин, в этом обычно нет необходимости.

Но когда машин становится много, приходится управлять ими более детально — иначе конфигурацию сложно
сопровождать и поддерживать.

У меня машин стало больше 20, и с ростом масштаба сложность начала выходить из-под контроля, поэтому
такая архитектура выглядит естественным и разумным выбором.

## Tests

Когда конфигурация простая, тесты не обязательны. Но с ростом количества машин и их настроек тесты
становятся всё важнее.

Здесь есть два типа тестов: eval tests и nixos tests. Оба помогают заранее ловить неочевидные ошибки,
чтобы меньше тестировать «вживую» и не ломать окружения — от личных машин до production.

Related projects & docs:

- [haumea](https://github.com/nix-community/haumea): Filesystem-based module system for Nix
- [Unveiling the Power of the NixOS Integration Test Driver (Part 1)](https://nixcademy.com/2023/10/24/nixos-integration-tests/)
- [NixOS Tests - NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)

### 1. Eval Tests

> TODO: More Tests!

Eval tests вычисляют выражения и сравнивают результат с expected. Они работают быстро, но не строят
«настоящую» машину. Мы используем eval tests, чтобы проверять корректность некоторых атрибутов для
каждого NixOS host (не Darwin).

Как запустить все eval tests:

```bash
nix eval .#evalTests --show-trace --print-build-logs --verbose
```

### 2. NixOS Tests

> WIP: not working yet

NixOS tests собирают и запускают виртуальные машины на базе нашей NixOS-конфигурации и выполняют
проверки внутри. По сравнению с eval tests это медленно, но зато поднимается реальная система и
можно тестировать, что всё действительно работает как ожидается.

Problems:

- [ ] We need a private cache server, so that our NixOS tests do not need to build some custom
      packages every time we run the tests.
- [ ] Cannot test the whole host, because my host relies on its unique ssh host key to decrypt its
      agenix secrets.
  - [ ] Maybe it's better to test every service separately, not the whole host?

Как запускать NixOS tests для каждого host:

```bash
# Format: nix build .#<name>-nixos-tests

nix build .#ruby-nixos-tests
```

## Overview

Все outputs этого flake определены здесь.

```bash
› tree
.
├── default.nix       # The entry point, all the outputs are composed here.
├── README.md
├── aarch64-linux     # All outputs for Linux ARM64
│   ├── default.nix
│   ├── src           # every host has its own file in this directory
│   │   ├── idols-akane.nix
│   └── tests         # eval tests
└── x86_64-linux      # All outputs for Linux x86_64
    ├── default.nix
    ├── nixos-tests
    ├── src           # every host has its own file in this directory
    │   ├── idols-ai.nix
    │   ├── idols-aquamarine.nix
    │   ├── idols-kana.nix
    │   ├── idols-ruby.nix
    │   ├── k3s-prod-1-master-1.nix
    │   ├── k3s-prod-1-master-2.nix
    │   ├── k3s-prod-1-master-3.nix
    │   ├── k3s-prod-1-worker-1.nix
    │   ├── k3s-prod-1-worker-2.nix
    │   ├── k3s-prod-1-worker-3.nix
    │   ├── kubevirt-shoryu.nix
    │   ├── kubevirt-shushou.nix
    │   └── kubevirt-youko.nix
    └── tests         # eval tests
        ├── home-manager
        │   ├── expected.nix
        │   └── expr.nix
        ├── hostname
        │   ├── expected.nix
        │   └── expr.nix
        └── kernel
            ├── expected.nix
            └── expr.nix
```
