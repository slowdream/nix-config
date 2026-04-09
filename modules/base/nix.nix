{
  pkgs,
  config,
  myvars,
  ...
}:
{
  nix.settings = {
    # flakes глобально
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # пользователям из списка разрешено задавать дополнительные substituters через:
    #    1. `nixConfig.substituers` в `flake.nix`
    #    2. аргументы CLI `--options substituers http://xxx`
    trusted-users = [ myvars.username ];

    # substituters смотрятся раньше официальных (https://cache.nixos.org)
    substituters = [
      # cache mirror в Китае
      # status: https://mirrors.ustc.edu.cn/status/
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # status: https://mirror.sjtu.edu.cn/
      # "https://mirror.sjtu.edu.cn/nix-channels/store"
      # others
      # "https://mirrors.sustech.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"

      "https://nix-community.cachix.org"
      # свой cache server — сейчас не используется
      # "https://ryan4yin.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "ryan4yin.cachix.org-1:Gbk27ZU5AYpGS9i3ssoLlwdvMIh0NxG0w8it/cv9kbU="
    ];
    builders-use-substitutes = true;
  };
}
