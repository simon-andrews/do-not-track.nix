# Assertions for the home-manager module, evaluated against real home-manager so
# that settings referencing real options are type-checked. A failure throws at
# evaluation time, failing `nix flake check`.
{ pkgs, home-manager }:
let
  lib = pkgs.lib;

  eval =
    extra:
    (home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../modules/home-manager.nix
        {
          home.username = "test";
          home.homeDirectory = "/home/test";
          home.stateVersion = "24.11";
        }
        extra
      ];
    }).config;

  default = eval { };
  noHomebrew = eval { doNotTrack.programs.homebrew.enable = false; };
  disabled = eval { doNotTrack.enable = false; };
  noStandard = eval { doNotTrack.standard.enable = false; };
  goEnabled = eval { programs.go.enable = true; };
  goDisabled = eval { programs.go.enable = false; };

  vars = c: c.home.sessionVariables;

  check = name: cond: lib.optional (!cond) name;

  failures =
    check "DO_NOT_TRACK set by default" (((vars default).DO_NOT_TRACK or null) == "1")
    ++ check "homebrew var set by default" (((vars default).HOMEBREW_NO_ANALYTICS or null) == "1")
    ++ check "per-program flag removes its var" (!((vars noHomebrew) ? HOMEBREW_NO_ANALYTICS))
    ++ check "per-program flag keeps other vars" (
      ((vars noHomebrew).DOTNET_CLI_TELEMETRY_OPTOUT or null) == "1"
    )
    # Real home-manager sets its own session vars, so assert OUR keys are absent,
    # not that the whole set is empty.
    ++ check "master disable drops our vars" (
      !((vars disabled) ? DO_NOT_TRACK) && !((vars disabled) ? HOMEBREW_NO_ANALYTICS)
    )
    ++ check "standard flag drops DO_NOT_TRACK" (!((vars noStandard) ? DO_NOT_TRACK))
    ++ check "go telemetry off when go enabled" (
      (goEnabled.programs.go.telemetry.mode or null) == "off"
    )
    ++ check "go telemetry untouched when go disabled" (
      (goDisabled.programs.go.telemetry.mode or null) == null
    );
in
if failures == [ ] then
  pkgs.runCommand "do-not-track-eval-tests" { } "touch $out"
else
  throw "do-not-track eval tests failed: ${lib.concatStringsSep ", " failures}"
