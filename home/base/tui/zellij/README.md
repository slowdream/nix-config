# Zellij - workspace в вашем терминале

Zellij — это terminal workspace «с батарейками из коробки». В основе это terminal multiplexer
(похоже на tmux и screen), но это лишь его инфраструктурный слой.

Zellij довольно дружелюбный и простой: есть пошаговая hint-система, которая помогает запомнить
keybindings — это похоже на опыт в Neovim или Helix.

> By contrast, tmux's key design is counterintuitive, there is no prompt system, and the plug-in
> performance is rubbish. It's really a pain to use. tmux's initial release was in 2007, it's too
> old, I would recommend any users that do not have a experience with multiplexer to use zellij
> instead of tmux.

## Почему использовать Zellij как default terminal environment?

Если auto start Zellij при входе в shell и завершать shell-сессию при выходе из Zellij, то Zellij
становится default terminal environment.

В таком подходе мы используем только базовые возможности terminal emulator (kitty/alacritty/wezterm/…),
а большую часть «терминальных функций» даёт Zellij. Благодаря этому можно легко переключаться между
terminal emulators без потери ключевых функций и не думать о различиях между ними.

И Zellij можно использовать не только локально, но и на любом remote server — удобно. Learn once and
use everywhere.

> Yeah, you didn't misread it, zellij is very suitable for not only remotely, but also locally!

Some features such as search/copy/scrollback in different terminal emulators are implemented in
different ways, and has different user experience. For example, Wezterm's default search function is
very basic, and it's not easy to use. Kitty's scrollback search/copy is really tricky to use. As for
some Editor such as Neovim, its integrated terminal is really useful, but zellij is more powerful
and useful than it, and more stable! Zellij overcomes these problems, and provides a unified user
experience for all terminal emulators!

Terminal emulators в идеале должны отвечать только за отображение символов.

## Passthrough mode(Lock Mode)

`Ctrl + g` lock the outer zellij interface, and all keys will be sent to the focused pane.

It's extremely useful when you want to:

1. Use zellij locally for daily work, and use a remote zellij via ssh to do some work on the remote
   server.
1. To avoid the key conflicts between zellij and the program running in the terminal, such as vim,
   tmux, etc.
