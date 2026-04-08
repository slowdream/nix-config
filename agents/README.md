# agents

Переиспользуемые ресурсы для agents (с упором на symlink-first), которые шарятся между проектами.

Эта директория — канонический источник baseline правил для agents и вспомогательных справочников по
командам. Основной workflow — делать symlink файлов отсюда в runtime/config локации конкретных agents.

## Что содержит эта директория

- `AGENTS.md`: global baseline rules для coding agents.
- `install-rules.py`: устанавливает baseline, создавая symlinks в поддерживаемых agent config dirs.
- `install-cli.md`: curated сниппеты команд для установки/обновления CLI.
- `install-skills.md`: curated сниппеты команд `npx skills`.

## Основной workflow

1. Поддерживайте общие правила в `agents/AGENTS.md`.
2. Запускайте `install-rules.py`, чтобы обновить symlinks в локальных agent homes.
3. Используйте `install-cli.md` и `install-skills.md` как справочные сниппеты при необходимости.

## Установка baseline правил (через symlink)

Запуск:

```bash
python3 agents/install-rules.py
```

Текущие targets:

- Codex: `AGENTS.md` -> `${CODEX_HOME:-~/.codex}/AGENTS.md`
- OpenCode: `AGENTS.md` -> `${XDG_CONFIG_HOME:-~/.config}/opencode/AGENTS.md`
- Claude Code: `AGENTS.md` -> `~/.claude/CLAUDE.md`
- Gemini: `AGENTS.md` -> `~/.gemini/GEMINI.md`

Поведение:

- Каждый target обрабатывается независимо.
- Если destination directory отсутствует — он пропускается.
- Если destination file/symlink уже существует — он заменяется symlink на source file в этом репозитории.

## Про `install-cli.md` и `install-skills.md`

Используйте их как библиотеки сниппетов:

- просмотрите команды
- выберите нужное
- запускайте выбранные команды вручную

## Соглашения

- Держите файлы portable и reviewable.
- Не храните в этой директории secrets и machine-specific credentials.
- Держите инструкции достаточно общими, чтобы переиспользовать их в разных agent environments.

## Цель

Поддерживать один переиспользуемый source of truth по настройке agents, который легко синхронизировать
и развивать.
