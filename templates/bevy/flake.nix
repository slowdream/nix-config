# https://github.com/bevyengine/bevy/blob/v0.14.2/docs/linux_dependencies.md#nix
{
  description = "Bevy Game Engine - Rust Lang";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      fenix,
      ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # Вспомогательная функция: attribute set на каждую system
      forAllSystems = func: (nixpkgs.lib.genAttrs systems func);
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ fenix.overlays.default ];
          };
          lib = pkgs.lib;
        in
        {
          default = pkgs.mkShell rec {
            nativeBuildInputs = with pkgs; [
              pkg-config
              clang
              # lld быстрее линкует, чем default Rust linker
              lld
            ];
            buildInputs =
              with pkgs;
              [
                # toolchain Rust
                (pkgs.fenix.complete.withComponents [
                  "cargo"
                  "clippy"
                  "rust-src"
                  "rustc"
                  "rustfmt"
                ])
                # rust-analyzer-nightly — лучше type inference
                rust-analyzer-nightly
                cargo-watch
              ]
              # https://github.com/bevyengine/bevy/blob/v0.14.2/docs/linux_dependencies.md#nix
              ++ (lib.optionals pkgs.stdenv.isLinux [
                udev
                alsa-lib
                vulkan-loader
                libX11
                libXcursor
                libXi
                libXrandr # x11 feature
                libxkbcommon
                wayland # wayland feature
              ])
              ;
            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
        }
      );
    };
}
