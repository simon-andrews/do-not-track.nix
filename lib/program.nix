# Schema every programs/*.nix must satisfy, applied to the entry *after* it has
# been resolved against the home-manager config (see home-manager.nix). A malformed
# file (unknown or mis-typed field) is an evaluation error that names the offending
# file. The id comes from the filename (see collect.nix), so it isn't part of the data.
{ lib }:
let
  inherit (lib) mkOption types;
  schema.options = {
    env = mkOption {
      description = "environment variables, always exported (gated only by the toggles)";
      type = types.attrsOf types.str;
      default = { };
    };
    settings = mkOption {
      description = "home-manager config merged in only when `enable` holds";
      type = types.attrs;
      default = { };
    };
    enable = mkOption {
      description = "a (type-checked) condition, e.g. `config.programs.go.enable`";
      type = types.bool;
      default = true;
    };
    references = mkOption {
      description = "documentation links";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  plain =
    file: field: v:
    lib.throwIf (
      (v._type or null) == "if"
    ) "${file}: `${field}` must be a plain attrset; gate with `enable`, not `lib.mkIf`." v;
in
file: data:
let
  guarded = data // {
    env = plain file "env" (data.env or { });
    settings = plain file "settings" (data.settings or { });
  };
  inherit
    (lib.evalModules {
      modules = [
        schema
        {
          _file = file;
          config = guarded;
        }
      ];
    })
    config
    ;
in
# Force the whole entry so a malformed file fails on touch, not only when a field is read.
lib.deepSeq config config
