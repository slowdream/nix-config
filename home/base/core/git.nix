{
  config,
  lib,
  pkgs,
  myvars,
  ...
}:
{
  # `programs.git` создаёт ~/.config/git/config;
  # чтобы git его читал, файла `~/.gitconfig` быть не должно!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  # GitHub CLI
  # https://cli.github.com/manual/
  programs.gh.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;

    # signing = {
    #   key = "xxx";
    #   signByDefault = true;
    # };

    includes = [
      {
        # отдельный email и имя для work:
        #
        # [user]
        #   email = "xxx@xxx.com"
        #   name = "Ryan Yin"
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    settings = {
      user.email = myvars.useremail;
      user.name = myvars.userfullname;

      init.defaultBranch = "main";
      trim.bases = "develop,master,main"; # для git-trim
      push.autoSetupRemote = true;
      pull.rebase = true;
      log.date = "iso"; # дата в ISO-формате

      # https -> ssh
      url = {
        "ssh://git@github.com/ryan4yin" = {
          insteadOf = "https://github.com/ryan4yin";
        };
        # "ssh://git@bitbucket.com/ryan4yin" = {
        #   insteadOf = "https://bitbucket.com/ryan4yin";
        # };
      };

      alias = {
        # частые алиасы
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
        ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
        cm = "commit -m"; # коммит: `git cm <message>`
        ca = "commit -am"; # всё закоммитить: `git ca <message>`
        dc = "diff --cached";

        amend = "commit --amend -m"; # правка сообщения: `git amend <message>`
        unstage = "reset HEAD --"; # убрать из индекса: `git unstage <file>`
        merged = "branch --merged"; # влитые в HEAD: `git merged`
        unmerged = "branch --no-merged"; # не влитые в HEAD: `git unmerged`
        nonexist = "remote prune origin --dry-run"; # несуществующие на remote: `git nonexist`

        # удалить влитые ветки, кроме master / dev / staging
        #  `!` — shell-скрипт, не подкоманда git
        delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
        # удалить ветки, которых уже нет на remote
        delnonexist = "remote prune origin";

        # submodule
        update = "submodule update --init --recursive";
        foreach = "submodule foreach";
      };
    };
  };

  # Пейджер с подсветкой для git diff / grep / blame
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      diff-so-fancy = true;
      line-numbers = true;
      true-color = "always";
      # features — именованные группы настроек
      # features = "";
    };
  };

  # Git TUI на Go
  programs.lazygit.enable = true;

  # Ещё один Git TUI на Rust
  programs.gitui.enable = false;
}
