{ config, ... }:
{
  # чтобы `npm install -g <pkg>` работал без сюрпризов
  #
  # в основном для npm-пакетов, которые часто обновляются,
  # например opencode, codex и т.п.
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm
  '';
}
