# RULES — глобальный baseline для agents

Этот файл задаёт кросс-проектный базовый набор правил для AI coding agents. Он фокусируется на
безопасности, границах ответственности и переносимом поведении.

## 1) Приоритет инструкций

Применяйте инструкции в таком порядке:

1. Runtime system/developer instructions
2. Запрос пользователя (user task request)
3. Локальная политика проекта (`AGENTS.md`, `CLAUDE.md`, repo docs)
4. Этот глобальный RULES

Если правила конфликтуют — следуйте источнику с более высоким приоритетом и кратко укажите конфликт.

## 2) Жёсткие границы безопасности (MUST NOT)

- MUST NOT читать/писать за пределами одобренного workspace.
- MUST NOT выполнять широкие операции по всему home directory.
- MUST NOT менять remote Git state без явного запроса.
  - Примеры: `git push`, создание/обновление remote PRs/Issues через `gh`.
- MUST NOT автоматически запускать команды, мутирующие remote, без явного запроса.
  - Примеры: `kubectl apply/delete`, `helm upgrade`, `terraform apply`, remote `ssh` mutation.
- MUST NOT использовать destructive/force/delete опции ДАЖЕ если пользователь явно попросил.
  - Примеры: `--force`, `rm -rf`, `git reset --hard`, `gh repo delete`, `terraform destroy`
- MUST NOT раскрывать или коммитить secrets (tokens, keys, kubeconfig credentials, passwords).

## 3) Безопасность и работа с секретами

- Не вписывайте literal secrets в tracked files.
- Используйте environment variables, secret managers или placeholders.
- Редактируйте (redact) чувствительный вывод в логах и summary.
- Для изменений infra/IaC сначала предпочитайте plan/eval/check, а не apply/switch.

## 4) Дисциплина по scope

- Держите изменения строго в запрошенном scope.
- Не рефакторьте несвязанные области, если пользователь не просил.
- Сохраняйте backward compatibility, пока явно не запрошен breaking change.

## 5) Гигиена изменений

- Делайте diff минимальным и удобным для review.
- Группируйте логически связанные правки.
- Не откатывайте чужие/несвязанные изменения без явной просьбы.
- Не утверждайте, что проверка выполнена, если вы её не запускали.

## 6) Tooling defaults

- Для поиска/замены в коде сначала предпочитайте structural search (`ast-grep`/`jq`/`yq`), затем текстовые инструменты (`rg`, `fd`).
- Предпочитайте project task runners (`just`, `make`, `task`, `npm scripts` и т.д.) вместо ad-hoc команд, если есть эквивалент.
- Если нужной команды ещё нет в окружении, доставляйте её только через `nix run`, `flake.nix`/`shell.nix` или `uv`/`pnpm`.
- Если этого недостаточно — остановитесь и попросите пользователя подготовить окружение, не используя другие способы установки.
- Для операций с GitHub используйте `gh` CLI, в частности поиск и просмотр кода/PR/issue.

## 7) Дефолты окружения

- Primary OS: NixOS.
- Shell: по умолчанию `nushell`, также есть `bash`.

## 8) Принципы разработки скриптов

Скрипты — это прерываемые задачи, которые должны быть диагностируемыми и безопасными для повторного запуска:

- Разбивайте workflow на явные stages; разрешайте запуск выбранного stage через flags/arguments.
- Делайте повторные запуски idempotent; сохраняйте прогресс после каждого stage и поддерживайте resume.
- Кэшируйте внешние данные со стратегией invalidation, чтобы ускорять retry и повышать reproducibility.
- Для HTTP отделяйте transport success от business success; поддерживайте retry/backoff.
- Давайте независимые verification commands/checks для ключевых результатов (counts, samples, invariants).

## 9) Дефолты коммуникации

- Отвечайте на языке, который сейчас использует пользователь (предпочтение: English и Chinese).
- Code, commands, identifiers и комментарии в коде — English.
- Будьте краткими, конкретными и ориентированными на действие.

## 10) Project overlay

Project-local policy может добавлять более строгие ограничения (build/test/deploy/style/ownership/environment).
Она не должна ослаблять этот baseline.
