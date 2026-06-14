# Schema every programs/*.nix must satisfy. Each entry is validated through the
# module system, so a malformed file (missing, unknown, or mis-typed field) is an
# evaluation error that names the offending file. The id comes from the filename
# (see collect.nix), so it isn't part of the data.
{ lib }:
let
  inherit (lib) mkOption types;
  schema.options = {
    # Drop attrsOf's emptyValue so env must be set explicitly, not silently {}.
    env = mkOption { type = types.attrsOf types.str // { emptyValue = { }; }; };
    references = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
in
file: data:
let
  inherit (lib.evalModules { modules = [ schema { _file = file; config = data; } ]; }) config;
in
# Force the whole entry so a malformed file fails on touch, not only when a field is read.
lib.deepSeq config config
