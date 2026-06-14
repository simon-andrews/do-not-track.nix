# home-manager module: maps the platform-agnostic program dataset onto
# home.sessionVariables.
{ config, lib, ... }:
let
  programs = import ../lib/collect.nix { inherit lib; };
  cfg = config.doNotTrack;
in
{
  options.doNotTrack = {
    enable = lib.mkEnableOption "telemetry and tracking opt-out environment variables" // {
      default = true;
    };

    standard.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Export DO_NOT_TRACK=1 (https://donottrack.sh).";
    };

    programs = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to disable telemetry for this program.";
          };
        }
      );
      default = { };
      description = "Per-program toggles. Every known program defaults to enabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Materialise a toggle entry for every known program (submodule default = enabled),
    # so cfg.programs.<id> always resolves.
    doNotTrack.programs = lib.genAttrs (map (p: p.id) programs) (_: { });

    home.sessionVariables = lib.mkMerge (
      [ (lib.mkIf cfg.standard.enable { DO_NOT_TRACK = "1"; }) ]
      ++ map (p: lib.mkIf cfg.programs.${p.id}.enable p.env) programs
    );
  };
}
