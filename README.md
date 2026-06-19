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

## Development

```console
$ nix develop      # nixd + nixfmt on PATH
$ nix flake check  # eval tests against real home-manager
$ nix fmt          # format all .nix files with nixfmt
```

Editor support is preconfigured for VS Code via [Nix IDE](https://github.com/nix-community/vscode-nix-ide)
(`.vscode/`), which drives the [nixd](https://github.com/nix-community/nixd) language
server. nixd is told to evaluate the module against this flake's pinned `nixpkgs`
and home-manager, so option completion and hover cover both home-manager options
and this flake's `doNotTrack.*` options. Run the editor from a `nix develop` shell
(or otherwise put `nixd`/`nixfmt` on PATH) so the extension can find them.
