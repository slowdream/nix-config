{
  pkgs,
  pkgs-master,
  ...
}:
{
  home.packages =
    with pkgs;
    (
      # -*- Data & Configuration Languages -*-#
      [
        #-- nix
        nil
        nixd
        statix # линт и подсказки для Nix
        deadnix # неиспользуемый код в .nix
        nixfmt # форматтер Nix

        #-- nickel
        nickel

        #-- json-подобные
        # terraform  # на macOS через brew
        terraform-ls
        jsonnet
        jsonnet-language-server
        taplo # TOML: LSP / formatter / validator
        yaml-language-server
        actionlint # линтер GitHub Actions

        #-- dockerfile
        hadolint
        dockerfile-language-server

        #-- markdown
        marksman # LSP для markdown
        glow # превью markdown
        pandoc # конвертер документов
        pkgs-master.hugo # static site generator

        #-- sql
        sqlfluff

        #-- protocol buffer
        buf # lint и format
      ]
      ++
        #-*- General Purpose Languages -*-#
        [
          #-- c/c++
          cmake
          cmake-language-server
          gnumake
          checkmake
          # компилятор c/c++ для nvim-treesitter
          gcc
          gdb
          # clang-tools: не unwrapped — иначе появятся `cc`/`c++` и конфликт с gcc
          # llvmPackages.clang-unwrapped
          clang-tools
          lldb
          vscode-extensions.vadimcn.vscode-lldb.adapter # codelldb

          #-- python
          uv # менеджер пакетов проекта
          pipx # изолированные Python-приложения
          (python313.withPackages (
            ps: with ps; [
              pyright
              ruff

              black # formatter

              # часто используемые пакеты
              jupyter
              ipython
              pandas
              requests
              pyquery
              pyyaml
              boto3

              # прочее
              protobuf
              numpy
            ]
          ))

          #-- rust
          # для разработки лучше rust-overlay
          pkgs-master.rustc
          pkgs-master.rust-analyzer
          pkgs-master.cargo
          pkgs-master.rustfmt
          pkgs-master.clippy

          #-- golang
          go
          gomodifytags
          iferr # шаблоны обработки ошибок
          impl # заготовки реализаций
          gotools # godoc, goimports, …
          gopls
          delve

          # -- java
          jdk17
          gradle
          maven
          spring-boot-cli
          jdt-language-server

          #-- zig
          zls

          #-- lua
          stylua
          lua-language-server

          #-- bash
          bash-language-server
          shellcheck
          shfmt
        ]
      #-*- Web -*-#
      ++ [
        nodejs_24
        pnpm
        typescript
        typescript-language-server
        bun
        # LSP из vscode: HTML/CSS/JSON/ESLint
        vscode-langservers-extracted
        tailwindcss-language-server
        emmet-ls
      ]
      # -*- Lisp -*-#
      # ++ [
      #   guile
      #   racket-minimal
      #   fnlfmt # fennel
      #   (
      #     if pkgs.stdenv.isLinux && pkgs.stdenv.isx86
      #     then pkgs-master.akkuPackages.scheme-langserver
      #     else pkgs.emptyDirectory
      #   )
      # ]
      ++ [
        proselint # линтер английской прозы

        #-- verilog / systemverilog
        verible

        #-- опционально
        prettier
        fzf
        gdu # для AstroNvim
        (ripgrep.override { withPCRE2 = true; }) # поиск по regex в дереве
      ]
    );
}
