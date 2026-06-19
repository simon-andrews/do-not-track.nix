{
  description = "Set-and-forget telemetry/tracking opt-out modules for home-manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      flake = {
        # Consumer entry point: imports = [ inputs.do-not-track.homeModules.default ];
        homeModules.default = ./modules/home-manager.nix;

        lib.programs = map (e: { inherit (e) id file; }) (import ./lib/collect.nix { lib = nixpkgs.lib; });
      };

      perSystem =
        { pkgs, ... }:
        {
          checks.eval = import ./checks/eval.nix {
            inherit pkgs;
            home-manager = inputs.home-manager;
          };

          # `nix fmt`: the official treefmt+nixfmt wrapper, which already recurses
          # the tree. (The editor formats separately via nixd's `formatting.command`.)
          formatter = pkgs.nixfmt-tree;

          # `nix develop` (and the tools the editor expects on PATH).
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.nixd
              pkgs.nixfmt
            ];
          };
        };
    };
}
