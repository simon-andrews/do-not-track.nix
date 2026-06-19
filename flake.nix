{
  description = "Set-and-forget telemetry/tracking opt-out modules for home-manager.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

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
        };
    };
}
