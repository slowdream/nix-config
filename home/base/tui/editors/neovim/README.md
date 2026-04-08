# Neovim Editor

Моя конфигурация Neovim основана на [AstroNvim](https://github.com/AstroNvim/AstroNvim). Подробнее
см. на сайте [AstroNvim](https://astronvim.com/).

В этом документе описана структура конфигурации Neovim и собраны shortcuts/commands для эффективной
работы.

## Скриншоты

![](/_img/astronvim_2023-07-13_00-39.webp) ![](/_img/hyprland_2023-07-29_2.webp)

## Структура конфигурации

| Описание                                         | Стандартное расположение                    | Моё расположение                                                          |
| ------------------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------- |
| Neovim's config                                   | `~/.config/nvim`                            | AstroNvim's github repository, referenced as a flake input in this flake. |
| AstroNvim's user configuration                    | `$XDG_CONFIG_HOME/astronvim/lua/user`       | [./astronvim_user/](./astronvim_user/)                                    |
| Plugins installation directory (lazy.nvim)        | `~/.local/share/nvim/`                      | The same as standard location, generated and managed by lazy.nvim.        |
| LSP servers, DAP servers, linters, and formatters | `~/.local/share/nvim/mason/`(by mason.nvim) | [./default.nix](./default.nix), installed by nix.                         |

## Обновление/очистка plugins

Важно: lazy.nvim не обновляет plugins автоматически, поэтому обновление нужно запускать вручную.

```bash
:Lazy update
```

Удалить неиспользуемые plugins:

```bash
:Lazy clean
```

## Тестирование

> via `Justfile` located at the root of this repo.

```bash
# testing
just nvim-test

# clear test data
just nvim-clear
```

## Cheatsheet

Это cheetsheet по моим конфигам Neovim. Перед этим рекомендую прочитать общий cheetsheet по vim в
[../README.md](../README.md).

### Incremental Selection

Функциональность даёт nvim-treesitter.

| Action            | Shortcut       |
| ----------------- | -------------- |
| init selection    | `<Ctrl-space>` |
| node incremental  | `<Ctrl-space>` |
| scope incremental | `<Alt-Space>`  |
| node decremental  | `Backspace`    |

### Поиск и прыжки (Search and Jump)

Функциональность даёт [flash.nvim](https://github.com/folke/flash.nvim) — plugin для умного поиска и
прыжков по тексту.

1. Он улучшает стандартный поиск/переходы в neovim (поиск с префиксом `/`).

| Action            | Shortcut                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------ |
| Search            | `/`(normal search), `s`(disable all code highlight, only highlight matches)                                  |
| Treesitter Search | `yR`,`dR`, `cR`, `vR`, `ctrl+v+R`(around your matches, all the surrounding Treesitter nodes will be labeled) |
| Remote Flash      | `yr`, `dr`, `cr`, (around your matches, all the surrounding Treesitter nodes will be labeled)                |

### Команды и shortcuts (Commands & Shortcuts)

| Action                        | Shortcut       |
| ----------------------------- | -------------- |
| Открыть file explorer         | `<Space> + e`  |
| Фокус на Neotree для текущего файла | `<Space> + o`  |
| Переключить перенос строк     | `<Space> + uw` |
| Показать line diagnostics     | `gl`           |
| Показать info по function/variable | `K`            |
| References of a symbol        | `gr`           |
| Следующая tab                 | `]b`           |
| Предыдущая tab                | `[b`           |

### Навигация по окнам (Window Navigation)

- Переключение между окнами: `<Ctrl> + h/j/k/l`
- Изменение размера окон: `<Ctrl> + Up/Down/Left/Right` (`<Ctrl-w> + -/+/</>`)
  - Примечание: на macOS конфликтует с system shortcuts
  - Отключение: System Preferences -> Keyboard -> Shortcuts -> Mission Control

### Сплиты и buffers (Splitting and Buffers)

| Action           | Shortcut      |
| ---------------- | ------------- |
| Horizontal Split | `\`           |
| Vertical Split   | `\|`          |
| Close Buffer     | `<Space> + c` |

### Редактирование и форматирование (Editing and Formatting)

| Action                                                | Shortcut       |
| ----------------------------------------------------- | -------------- |
| Переключить auto formatting для buffer               | `<Space> + uf` |
| Format Document                                       | `<Space> + lf` |
| Code Actions                                          | `<Space> + la` |
| Rename                                                | `<Space> + lr` |
| Opening LSP symbols                                   | `<Space> + lS` |
| Comment Line(support multiple lines)                  | `<Space> + /`  |
| Open filepath/URL at cursor(neovim's builtin command) | `gx`           |
| Find files by name (fzf)                              | `<Space> + ff` |
| Find files by name (include hidden files)             | `<Space> + fF` |
| Grep string in files (ripgrep)                        | `<Space> + fw` |
| Grep string in files (include hidden files)           | `<Space> + fW` |

### Git

| Action                     | Shortcut        |
| -------------------------- | --------------- |
| Git Commits (repository)   | `:<Space> + gc` |
| Git Commits (current file) | `:<Space> + gC` |
| Git Branches               | `:<Space> + gb` |
| Git Status                 | `:<Space> + gt` |

### Сессии (Sessions)

| Action                         | Shortcut       |
| ------------------------------ | -------------- |
| Сохранить session              | `<Space> + Ss` |
| Последняя session              | `<Space> + Sl` |
| Удалить session                | `<Space> + Sd` |
| Поиск session                  | `<Space> + Sf` |
| Загрузить session текущей директории | `<Space> + S.` |

### Отладка (Debugging)

Нажмите `<Space> + D`, чтобы посмотреть доступные bindings и options.

### Глобальный поиск и замена

| Описание                                  | Shortcut       |
| ------------------------------------------ | -------------- |
| Открыть panel поиска/замены spectre.nvim   | `<Space> + ss` |

Поиск и замена через cli (fd + sad + delta):

```bash
fd "\\.nix$" . | sad '<pattern>' '<replacement>' | delta
```

### Surrounding characters (Surrounding Characters)

Функциональность даёт plugin mini.surround.

- Prefix `gz`

| Action                         | Shortcut | Описание                                       |
| ------------------------------ | -------- | ----------------------------------------------- |
| Add surrounding characters     | `gzaiw'` | Добавить `'` вокруг слова под курсором          |
| Delete surrounding characters  | `gzd'`   | Удалить `'` вокруг слова под курсором           |
| Replace surrounding characters | `gzr'"`  | Заменить `'` на `"` вокруг слова под курсором   |
| Highlight surrounding          | `gzh'`   | Подсветить `'` вокруг слова под курсором        |

### Работа с текстом (Text Manipulation)

| Action                                 |               |
| -------------------------------------- | ------------- |
| Join with LSP intelligence(treesj)     | `<Space> + j` |
| Split Line into Multiple Lines(treesj) | `<Space> + s` |

### Разное (Miscellaneous)

| Action                            |                 |
| --------------------------------- | --------------- |
| Показать Yank History             | `:<Space> + yh` |
| Показать undo history             | `:<Space> + uh` |
| Показать путь текущего файла      | `:!echo $%`     |

## Дополнительные материалы

Для более подробной информации и продвинутого использования см.:

1. [AstroNvim walkthrough](https://astronvim.com/Basic%20Usage/walkthrough)
2. [./astronvim_user/mapping.lua](./astronvim_user/mappings.lua)
3. Документацию всех используемых plugins
