# Auto-discover every program definition under ../programs.
# Adding a new program = dropping a new file in that directory; nothing else changes.
{ lib }:
let
  dir = ../programs;
  isNixFile = name: type: type == "regular" && lib.hasSuffix ".nix" name;
  nixFiles = lib.filterAttrs isNixFile (builtins.readDir dir);
  # id is the filename without its extension, e.g. homebrew.nix -> "homebrew".
  load = name: { id = lib.removeSuffix ".nix" name; } // import (dir + "/${name}");
in
lib.mapAttrsToList (name: _: load name) nixFiles
