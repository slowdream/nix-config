# Terminal Emulators

Раньше я тратил много времени на настройку terminal emulators «под себя», но со временем понял, что
это не так уж и выгодно: **Zellij может дать дружелюбный и единый user experience для любых terminal
emulators — без боли**.

Сейчас я использую только базовые возможности terminal emulators (true color, graphics protocol и
т.д.). Все остальные функции вроде tabs, scrollback buffer, select/search/copy и т.п. даёт Zellij.

My current terminal emulators are:

1. kitty: My main terminal emulator.
   1. to select/copy a large mount of text, We should do some tricks via kitty's `scrollback_pager`
      with neovim, it's really painful: <https://github.com/kovidgoyal/kitty/issues/719>
2. foot: A fast, lightweight and minimalistic Wayland terminal emulator.
   1. foot only do the things a terminal emulator should do, no more, no less.
   1. It's really suitable for tiling window manager or zellij users!
3. alacritty: A cross-platform, GPU-accelerated terminal emulator.
   1. alacritty is really fast, I use it as a backup terminal emulator on all my desktops.

## 'xterm-kitty': unknown terminal type when `ssh` into a remote host or `sudo xxx`

> https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work

> https://wezfurlong.org/wezterm/config/lua/config/term.html

kitty по умолчанию выставляет `TERM` в `xterm-kitty`, и TUI приложения (например `viu`, `yazi`,
`curses`) будут искать в [terminfo(terminal capability data base)](https://linux.die.net/man/5/terminfo)
запись для значения `TERM`, чтобы определить возможности терминала.

Но когда вы делаете `ssh` на remote host, там часто нет `xterm-kitty` в terminfo — и вы увидите:

```
'xterm-kitty': unknown terminal type
```

Либо при `sudo xxx` переменная `TERM` не сохраняется: `sudo` сбрасывает её в root-значение (обычно
`xterm` или `xterm-256color` в большинстве linux distributions) — и вы получите:

```
'xterm-256color': unknown terminal type
```

or

```
Error opening terminal: xterm-kitty.
```

NixOS сохраняет environment variables `TERMINFO` и `TERMINFO_DIRS` для `root` и группы `wheel`:
[nixpkgs/nixos/modules/config/terminfo.nix](https://github.com/NixOS/nixpkgs/blob/nixos-25.11/nixos/modules/config/terminfo.nix#L18)

### Solutions

Самый простой вариант: он автоматически скопирует terminfo и «магически» включит shell integration на
remote машине:

```
kitten ssh user@host
```

Если функции kitty (true color, graphics protocol и т.д.) не важны — можно просто выставить `TERM` в
`xterm-256color`, который встроен в большинство linux distributions:

```
export TERM=xterm-256color
```

Если вам нужны фичи kitty, но не нравится «магия» `kitten`, можно вручную поставить terminfo kitty на
remote host:

```bash
# install on ubuntu / debian
sudo apt-get install kitty-terminfo

# or copy from local machine
infocmp -a xterm-kitty | ssh myserver tic -x -o \~/.terminfo /dev/stdin
```
