{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-parts, nixpkgs }@inputs:
    let
      inherit (flake-parts.lib) mkFlake;
    in
    mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = { config, pkgs, ... }:
        let
          wez-status-generator = pkgs.callPackage ./package.nix { };
        in
        {
          packages = { default = wez-status-generator; };

          devShells = {
            default = pkgs.callPackage ./dev-shell.nix {
              inherit wez-status-generator;
            };
          };
        };
    };
}
