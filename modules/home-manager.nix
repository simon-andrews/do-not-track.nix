# home-manager module: maps the program dataset onto home.sessionVariables (env
# vars, always on) and, for programs that need it, onto real home-manager options
# gated on a type-checked condition (settings + enable).
{
  config,
  lib,
  ...
}:
let
  entries = import ../lib/collect.nix { inherit lib; };
  validate = import ../lib/program.nix { inherit lib; };
  ids = map (e: e.id) entries;

  # One submodule per program. `_file` attributes any option error (e.g. a settings
  # entry referencing an option that doesn't exist) back to the program's source file.
  programModule =
    e:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.doNotTrack;
      # Resolve the (possibly config-dependent) file, then validate the result.
      data = validate e.file ((lib.toFunction e.raw) { inherit config lib pkgs; });
    in
    {
      _file = e.file;
      config = lib.mkIf (cfg.enable && cfg.programs.${e.id}.enable) (
        lib.mkMerge [
          { home.sessionVariables = data.env; }
          (lib.mkIf data.enable data.settings)
        ]
      );
    };

  cfg = config.doNotTrack;
in
{
  imports = map programModule entries;

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
    doNotTrack.programs = lib.genAttrs ids (_: { });

    home.sessionVariables = lib.mkIf cfg.standard.enable { DO_NOT_TRACK = "1"; };
  };
}
