{ catppuccin, ... }:
{
  # https://github.com/catppuccin/nix
  imports = [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    # Значение `enable` по умолчанию для всех доступных программ.
    enable = true;
    # одно из: "latte", "frappe", "macchiato", "mocha"
    flavor = "mocha";
    # одно из: "blue", "flamingo", "green", "lavender", "maroon", "mauve", "peach", "pink", "red", "rosewater", "sapphire", "sky", "teal", "yellow"
    accent = "pink";
  };
}
