# do-not-track.nix

Disable telemetry and other unnecessary data collection across your Nix config with
a single set-and-forget Flake import. Inspired by [donottrack.sh](https://donottrack.sh).

## Usage

Add the input:

```nix
# flake.nix
inputs.do-not-track.url = "github:simon-andrews/do-not-track.nix";
```

Import the module:

```nix
# home.nix
{ inputs, ... }:
{
  imports = [ inputs.do-not-track.homeModules.default ];
}
```

After `home-manager switch`, the variables are set in new shells:

```console
$ printenv DO_NOT_TRACK HOMEBREW_NO_ANALYTICS
1
1
```

## Configuration

```nix
{
  # Turn everything off.
  doNotTrack.enable = false;

  # Skip DO_NOT_TRACK=1.
  doNotTrack.standard.enable = false;

  # Re-enable telemetry for one program.
  doNotTrack.programs.homebrew.enable = false;
}
```
