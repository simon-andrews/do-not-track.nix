# Lightweight, dependency-free assertions for the home-manager module.
# Uses lib.evalModules with a stub home.sessionVariables option so we can exercise
# the module's logic without pulling in home-manager itself.
{ pkgs }:
let
  lib = pkgs.lib;

  sessionVars =
    mods:
    (lib.evalModules {
      modules = mods ++ [
        ../modules/home-manager.nix
        (
          { lib, ... }:
          {
            options.home.sessionVariables = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
            };
          }
        )
      ];
    }).config.home.sessionVariables;

  default = sessionVars [ ];
  noHomebrew = sessionVars [ { doNotTrack.programs.homebrew.enable = false; } ];
  disabled = sessionVars [ { doNotTrack.enable = false; } ];
  noStandard = sessionVars [ { doNotTrack.standard.enable = false; } ];

  check = name: cond: lib.optional (!cond) name;

  failures =
    check "DO_NOT_TRACK set by default" ((default.DO_NOT_TRACK or null) == "1")
    ++ check "homebrew var set by default" ((default.HOMEBREW_NO_ANALYTICS or null) == "1")
    ++ check "per-program flag removes its var" (!(noHomebrew ? HOMEBREW_NO_ANALYTICS))
    ++ check "per-program flag keeps other vars" ((noHomebrew.DOTNET_CLI_TELEMETRY_OPTOUT or null) == "1")
    ++ check "master disable produces no vars" (disabled == { })
    ++ check "standard flag drops DO_NOT_TRACK" (!(noStandard ? DO_NOT_TRACK));
in
if failures == [ ] then
  pkgs.runCommand "do-not-track-eval-tests" { } "touch $out"
else
  throw "do-not-track eval tests failed: ${lib.concatStringsSep ", " failures}"
