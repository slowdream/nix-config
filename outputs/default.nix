{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };

  # Кастомный lib, vars, инстанс nixpkgs и все inputs в specialArgs,
  # чтобы использовать их во всех nixos/home-manager модулях.
  genSpecialArgs =
    system:
    inputs
    // {
      inherit mylib myvars;

      # unstable для части пакетов — свежие обновления
      # pkgs-unstable = import inputs.nixpkgs-unstable {
      #   inherit system; # `system` из внешней области видимости
      #   # Chrome: нужен non-free software
      #   config.allowUnfree = true;
      # };
      pkgs-2505 = import inputs.nixpkgs-2505 {
        inherit system;
        # Chrome: нужен non-free software
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        # Chrome: нужен non-free software
        config.allowUnfree = true;
      };
      pkgs-patched = import inputs.nixpkgs-patched {
        inherit system;
        # Chrome: нужен non-free software
        config.allowUnfree = true;
      };
      pkgs-master = import inputs.nixpkgs-master {
        inherit system;
        # Chrome: нужен non-free software
        config.allowUnfree = true;
      };

      pkgs-x64 = import nixpkgs {
        system = "x86_64-linux";

        # Chrome: нужен non-free software
        config.allowUnfree = true;
      };
    };

  # Аргументы для всех haumea-модулей в этой папке.
  args = {
    inherit
      inputs
      lib
      mylib
      myvars
      genSpecialArgs
      ;
  };

  # модули для каждой поддерживаемой system
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
    # riscv64-linux = import ./riscv64-linux (args // {system = "riscv64-linux";});
  };
  allSystems = nixosSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  allSystemValues = nixosSystemValues;

  # Вспомогательная функция: attribute set на каждую system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # Доп. attribute sets в outputs для отладки
  debugAttrs = {
    inherit
      nixosSystems
      allSystems
      allSystemNames
      ;
  };

  # NixOS hosts
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # Colmena — remote deploy по SSH
  colmena = {
    meta =
      (
        let
          system = "x86_64-linux";
        in
        {
          # default nixpkgs и specialArgs у colmena
          nixpkgs = import nixpkgs { inherit system; };
          specialArgs = genSpecialArgs system;
        }
      )
      // {
        # nixpkgs и specialArgs per-node
        nodeNixpkgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeNixpkgs or { }) nixosSystemValues
        );
        nodeSpecialArgs = lib.attrsets.mergeAttrsList (
          map (it: it.colmenaMeta.nodeSpecialArgs or { }) nixosSystemValues
        );
      };
  }
  // lib.attrsets.mergeAttrsList (map (it: it.colmena or { }) nixosSystemValues);

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # Eval tests для всех NixOS system.
  evalTests = lib.lists.all (it: it.evalTests == { }) allSystemValues;

  checks = forAllSystems (system: {
    # eval-tests на каждую system
    eval-tests = allSystems.${system}.evalTests == { };

    pre-commit-check = pre-commit-hooks.lib.${system}.run {
      src = mylib.relativeToRoot ".";
      hooks = {
        nixfmt-rfc-style = {
          enable = true;
          settings.width = 100;
        };
        # spell checker для исходников
        typos = {
          enable = true;
          settings = {
            write = true; # автоисправление typos
            configPath = ".typos.toml"; # от корня flake
            exclude = "rime-data/";
          };
        };
        prettier = {
          enable = true;
          settings = {
            write = true; # автоформатирование файлов
            configPath = ".prettierrc.yaml"; # от корня flake
          };
        };
        # deadnix.enable = true; # неиспользуемые bindings в `*.nix`
        # statix.enable = true; # линты и подсказки для Nix (auto suggestions)
      };
    };
  });

  # Development shells
  devShells = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # см. https://discourse.nixos.org/t/non-interactive-bash-errors-from-flake-nix-mkshell/33310
          bashInteractive
          # `cc` не должен быть только clang — иначе ошибки сборки nvim-treesitter
          gcc
          # всё про Nix
          nixfmt
          deadnix
          statix
          # spell checker
          typos
          # code formatter
          prettier
        ];
        name = "dots";
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    }
  );

  # Форматирование nix в этом flake
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
}
