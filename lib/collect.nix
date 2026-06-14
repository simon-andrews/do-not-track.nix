# Auto-discover every program definition under ../programs.
# Adding a new program = dropping a new file in that directory; nothing else changes.
{ lib }:
let
  dir = ../programs;
  validate = import ./program.nix { inherit lib; };
  isNixFile = name: type: type == "regular" && lib.hasSuffix ".nix" name;
  nixFiles = lib.filterAttrs isNixFile (builtins.readDir dir);
  load =
    name:
    let
      file = dir + "/${name}";
    in
    # id is the filename without its extension, e.g. homebrew.nix -> "homebrew".
    { id = lib.removeSuffix ".nix" name; } // validate (toString file) (import file);
in
lib.mapAttrsToList (name: _: load name) nixFiles
