# На основе дефолтного конфига:
#    ```
#    config nu --default
#    ```
#
# Документация Nushell Config
#
# Внимание: файл в первую очередь для документации настроек,
# не обязательно использовать как готовый конфиг без правок.
#
# version = "0.103.0"
#
# `config.nu` переопределяет дефолты Nushell, задаёт команды
# (или импорты) и другой startup-код.
# См. https://www.nushell.sh/book/configuration.html
#
# У большинства опций разумные defaults — в `config.nu` меняют только нужное.
#
# Этот файл — краткая «внутришелловая» документация по опциям;
# подробнее в книге: https://nushell.sh/book/configuration
#
# Красивый вывод документации:
# config nu --doc | nu-highlight | less -R

# $env.config
# -----------
# `$env.config` — record с основными настройками Nushell.
# Если подставить целиком новый record, пропадут ключи, которых в нём нет;
# Nushell подмешает внутренние defaults для недостающих.
#
# То же для вложенных record/list в `$env.config`.
#
# Обычно меняют отдельные ключи или делают merge; см. главу Configuration в книге.


$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000

# isolation (bool):
# `true`: история из других открытых сессий Nushell не видна при PrevHistory (часто Up)
#   и NextHistory (Down)
# `false`: команды из других сессий смешиваются с текущей.
# Примечание: старые записи (до старта этой сессии) всегда показываются.
# Только для SQLite history
$env.config.history.isolation = true

# ----------------------
# Прочие настройки
# ----------------------

# show_banner (bool): приветственный баннер при старте
$env.config.show_banner = false

# rm.always_trash (bool):
# true: rm как с --trash/-t
# false: rm как с --permanent/-p (default)
$env.config.rm.always_trash = true

# recursion_limit (int): сколько раз команда может вызвать себя рекурсивно до ошибки
$env.config.recursion_limit = 50

# ---------------------------
# Редактор командной строки
# ---------------------------

# edit_mode (string): "vi" или "emacs" — режим Reedline
$env.config.edit_mode = "vi"

# Команда для правки текущей строки по Ctrl+O.
# Если не задано — $env.VISUAL, затем $env.EDITOR
#
$env.config.buffer_editor = ["nvim", "--clean"]

# cursor_shape_* (string)
# -----------------------
# Допустимые значения:
# "block", "underscore", "line", "blink_block", "blink_underscore", "blink_line", "inherit"
# "inherit" — не трогать форму курсора, оставить как в терминале
$env.config.cursor_shape.emacs = "inherit"         # emacs mode
$env.config.cursor_shape.vi_insert = "block"       # vi insert
$env.config.cursor_shape.vi_normal = "underscore"  # vi normal

# --------------------
# Интеграция с терминалом
# --------------------
# Nushell может слать escape-последовательности для фич терминала.
# Неподдерживаемое можно отключить; при конфликте с терминалом — тоже.

# use_kitty_protocol (bool):
# Протокол клавиатуры Kitty: больше комбинаций. Без него Ctrl+I = Tab;
# с протоколом Ctrl+I и Tab раздельно.
$env.config.use_kitty_protocol = false

# osc2 (bool):
# true: в заголовке вкладки/окна — текущая директория и команда;
# домашний каталог сокращается через ~.
$env.config.shell_integration.osc2 = true

# osc7 (bool):
# Текущая директория в терминал через OSC 7 (удобно для новых вкладок в том же каталоге).
$env.config.shell_integration.osc7 = true

# osc9_9 (bool):
# OSC 9;9 (ConEmu и др.) — альтернатива OSC 7 для передачи пути.
$env.config.shell_integration.osc9_9 = false

# osc8 (bool):
# true: `ls` даёт кликабельные ссылки, если терминал умеет.
# Заменяет устаревший `ls.clickable_links`
$env.config.shell_integration.osc8 = true

# osc133 (bool):
# OSC 133: prompt/output/exit code для терминала (Final Term и др.) —
# отдельные цвета prompt/output, сворачивание вывода, скролл между prompt.

$env.config.shell_integration.osc133 = true

# osc633 (bool):
# OSC 633 — расширение OSC 133 для Visual Studio Code
$env.config.shell_integration.osc633 = true

# NU_LIB_DIRS
# -----------
# Каталоги для `use` и `source`.
#
# По умолчанию есть подкаталог `scripts` в стандартном config dir:
const NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # completions по умолчанию
]

# NU_PLUGIN_DIRS
# --------------
# Поиск бинарников плагинов для add.

# По умолчанию подкаталог `plugins`:
const NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # <nushell-config-dir>/plugins
]

# Как с NU_LIB_DIRS, сначала константа, потом при необходимости $env.NU_PLUGIN_DIRS

# `path add` из std — prepend в PATH:
use std/util "path add"
path add "~/.local/bin"

# Убрать дубликаты в PATH:
$env.PATH = ($env.PATH | uniq)

