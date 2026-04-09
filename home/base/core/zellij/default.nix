let
  shellAliases = {
    "zj" = "zellij";
  };
in
{
  programs.zellij = {
    enable = true;
  };
  # только bash/zsh, не nushell
  home.shellAliases = shellAliases;
  programs.nushell.shellAliases = shellAliases;
}
