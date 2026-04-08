# Editors

Мои редакторы:

1. Neovim
2. Helix

И `Zellij` — чтобы терминал был «гладким» и стабильным.

## Tips

1. Многие полезные команды уже есть в vim — прежде чем ставить новый plugin (или reinvent the wheel),
   проверьте документацию vim/neovim.
1. Когда освоитесь с Emacs/Neovim, очень рекомендую прочитать официальную документацию Neovim/vim:
   1. <https://vimhelp.org/>: The official vim documentation.
   1. <https://neovim.io/doc/user/>: Neovim's official user documentation.
1. Используйте Zellij для terminal операций, а Neovim/Helix — для редактирования.
1. Если используете Emacs — удобнее GUI версия и terminal emulator `vterm` для terminal операций.
1. Два мощных инструмента для поиска файлов и быстрого перехода:
1. Tree-view plugins дружелюбны к новичкам и интуитивны, но обычно менее эффективны.
1. **Search по file path**: полезно, когда вы хорошо знаете структуру проекта, особенно на больших
   проектах.
1. **Search по содержимому**: полезно, когда вы знакомы с кодом.

## Tutorial

Введите `:tutor` (или `:Tutor` в Neovim), чтобы пройти базовое обучение vim/neovim.

## Cheetsheet для vim

> Здесь записаны только мои часто используемые клавиши. Более полный cheetsheet:
> <https://vimhelp.org/quickref.txt.html>

Emacs-Evil и Neovim совместимы с vim, поэтому key-bindings ниже общие для Emacs-Evil, Neovim и vim.

### Terminal Related

Я в основном использую Zellij для terminal задач; вот shortcuts, которые чаще всего использую:

| Action                    | Zellij's Shortcut |
| ------------------------- | ----------------- |
| Floating Terminal         | `Ctrl + p + w`    |
| Horizontal Split Terminal | `Ctrl + p + d`    |
| Vertical Split Terminal   | `Ctrl + p + n`    |
| Execute a command         | `!xxx`            |

### File Management

> <https://neovim.io/doc/user/usr_22.html>

> <https://vimhelp.org/editing.txt.html>

| Action                              |                                                  |
| ----------------------------------- | ------------------------------------------------ |
| Save selected text to a file        | `:w filename` (Will show `:'<,'>w filename`)     |
| Save and close the current buffer   | `:wq`                                            |
| Save all buffers                    | `:wa`                                            |
| Save and close all buffers          | `:wqa`                                           |
| Edit a file                         | `:e filename`(or `:e <TAB>` to show a file list) |
| Browse the file list                | `:Ex` or `:e .`                                  |
| Discard changes and reread the file | `:e!`                                            |

### Motion

> https://vimhelp.org/motion.txt.html

| Action                                              | Command                                            |
| --------------------------------------------------- | -------------------------------------------------- |
| Move to the start/end of the buffer                 | `gg`/`G`                                           |
| Move the line number 5                              | `5gg` / `5G`                                       |
| Move left/down/up/right                             | h/j/k/l or `5h`/`5j`/`5k`/`5l` or `Ctr-n`/`Ctrl-p` |
| Move to the matchpairs, default to `()`, `{}`, `[]` | `%`                                                |
| Move to the start/end of the line                   | `0` / `$`                                          |
| Move a sentence forward/backward                    | `(` / `)`                                          |
| Move a paragraph forward/backward                   | `{` / `}`                                          |
| Move a section forward/backward                     | `[[` / `]]`                                        |
| Jump to various positions                           | `'` + some other keys(neovim has prompt)           |

Text Objects:

- **sentence**: text ending at a '.', '!' or '?' followed by either the end of a line, or by a space
  or tab.
- **paragraph**: text ending at a blank line.
- **section**: text starting with a section header and ending at the start of the next section
  header (or at the end of the file). - The "`]]`" and "`[[`" commands stop at the '`{`' in the
  first column. This is useful to find the start of a function in a C/Go/Java/... program.

### Text Manipulation

Basics:

| Action                                  |                            |
| --------------------------------------- | -------------------------- |
| Delete the current character            | `x`                        |
| Paste the copied text                   | `p`                        |
| Delete the selection                    | `d`                        |
| Undo the last word                      | `CTRL-w`(in insert mode)   |
| Undo the last line                      | `CTRL-u`(in insert mode)   |
| Undo the last change                    | `u`                        |
| Redo the last change                    | `Ctrl + r`                 |
| Inserts the text of the previous insert | `Ctrl + a`                 |
| Repeat the last command                 | `.`                        |
| Toggle text's case                      | `~`                        |
| Convert to uppercase                    | `U` (visual mode)          |
| Convert to lowercase                    | `u` (visual mode)          |
| Align the selected content              | `:center`/`:left`/`:right` |

Misc:

| Action                        | Shortcut                                 |
| ----------------------------- | ---------------------------------------- |
| Toggle visual mode            | `v` (lower case v)                       |
| Select the current line       | `V` (upper case v)                       |
| Toggle visual block mode      | `<Ctrl> + v` (select a block vertically) |
| Fold the current code block   | `zc`                                     |
| Unfold the current code block | `zo`                                     |
| Jump to Definition            | `gd`                                     |
| Jump to References            | `gD`                                     |
| (Un)Comment the current line  | `gcc`                                    |

| Action                                                                    |                |
| ------------------------------------------------------------------------- | -------------- |
| Sort the selected lines                                                   | `:sort`        |
| Join Selection of Lines With Space                                        | `:join` or `J` |
| Join without spaces                                                       | `:join!`       |
| Enter Insert mode at the start/end of the line                            | `I` / `A`      |
| Delete from the cursor to the end of the line                             | `D`            |
| Delete from the cursor to the end of the line, and then enter insert mode | `C`            |

Advance Techs:

- Add at the end of multiple lines: `:normal A<text>`
  - Execublock: `:A<text>`
  - visual block mode(ctrl + v)
  - Append text at the end of each line in the selected block
  - If position exceeds line end, neovim adds spaces automatically

- Delete the last char of multivle lines: `:normal $x`
  - Execute `$x` on each line
  - visual mode(v)
  - `$` moves cursor to the end of line
  - `x` deletes the character under the cursor

- Delete the last word of multiple lines: `:normal $bD`
  - Execute `$bD` on each line
  - visual mode(v)
  - `$` moves cursor to the end of line
  - `b` moves cursor to the beginning of the last word

### Search

| Action                                                | Command   |
| ----------------------------------------------------- | --------- |
| Search forward/backword for a pattern                 | `/` / `?` |
| Repeat the last search in the same/opposite direction | `n` / `N` |

### Find and Replace

| Action                           | Command                             |
| -------------------------------- | ----------------------------------- |
| Replace in selected area         | `:s/old/new/g`                      |
| Replace in current line          | Same as above                       |
| Replace all the lines            | `:% s/old/new/g`                    |
| Replace all the lines with regex | `:% s@\vhttp://(\w+)@https://\1@gc` |

1. `\v` означает, что в regex можно использовать «очевидный» синтаксис без лишних backslash-экранирований
   (аналогично raw string в Python).
2. `\1` — это первая захваченная группа в шаблоне.

### Replace in the specific lines

| Action                                    | Command                                |
| ----------------------------------------- | -------------------------------------- |
| From the 10th line to the end of the file | `:10,$ s/old/new/g` or `:10,$ s@^@#@g` |
| From the 10th line to the 20th line       | `:10,20 s/old/new/g`                   |
| Remove the trailing spaces                | `:% s/\s\+$//g`                        |

Postfix(flags) в командах выше:

1. `g` — заменить все совпадения в текущей строке/файле.
2. `c` — спрашивать подтверждение перед заменой.
3. `i` — ignore case.

### Buffers, Windows and Tabs

> <https://neovim.io/doc/user/usr_08.html>

> <https://vimhelp.org/windows.txt.html>

- buffer — текст файла в памяти.
- window — «окно просмотра» для buffer.
- tab page — набор windows.

| Action                              | Command                             |
| ----------------------------------- | ----------------------------------- |
| Split the window horizontally       | `:sp[lit]` or `:sp filename`        |
| Split the window horizontally       | `:vs[plit]` or `:vs filename`       |
| Switch to the next/previous window  | `Ctrl-w + w` or `Ctrl-w + h/j/k/l`  |
| Show all buffers                    | `:ls`                               |
| show next/previous buffer           | `]b`/`[b` or `:bn[ext]` / `bp[rev]` |
| New Tab(New Workspace in DoomEmacs) | `:tabnew`                           |
| Next/Previews Tab                   | `gt`/`gy`                           |

### History

| Action                   | Command |
| ------------------------ | ------- |
| Show the command history | `q:`    |
| Show the search history  | `q/`    |
