# fastpotify.nix

A Nix package and overlay for [Fastpotify](https://fastpotify.rocks/), built from the upstream release source.

## Run without installing

```sh
nix run github:gnkz/fastpotify.nix
```

## Install in a user profile

```sh
nix profile install github:gnkz/fastpotify.nix
```

Upgrade it later with:

```sh
nix profile upgrade fastpotify
```

## Install on NixOS

Add this repository as a flake input and apply its overlay:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fastpotify.url = "github:gnkz/fastpotify.nix";
  };

  outputs =
    { nixpkgs, fastpotify, ... }:
    {
      nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ fastpotify.overlays.default ];
            environment.systemPackages = [ pkgs.fastpotify ];
          })
        ];
      };
    };
}
```

The same overlay works with Home Manager. After adding it to `nixpkgs.overlays`, add `pkgs.fastpotify` to `home.packages`.

## Outputs

- `packages.<system>.fastpotify` and `packages.<system>.default`
- `overlays.default`, which adds `pkgs.fastpotify`

Supported system: `x86_64-linux`.

## Maintenance

Requires `just`, Nix with flakes enabled, Git, Bash, and `jq`. Run `just` to list tasks:

```sh
just build    # Build Fastpotify
just check    # Check the flake
just fmt      # Format Nix files
just release  # Update Fastpotify, validate, commit, and push
just update   # Update flake inputs, validate, commit, and push
```

`release` uses `nix-update` from the pinned nixpkgs to find the latest stable
Fastpotify version and update its source and Cargo hashes. It fails if there is
no newer version. Commits look like `fastpotify: 0.4.1 -> 0.4.2`.

`update` runs `nix flake update` and fails if the lock file is unchanged. Commits
include the old and new nixpkgs revisions, e.g.
`flake: update nixpkgs e8be781 -> 5545adf`.

Both publishing tasks require a clean working tree (including untracked files)
and a branch with a configured upstream. They check the flake and build
Fastpotify before committing only the relevant file, then run `git push`.
Updates that fail validation are left uncommitted for inspection; if pushing
fails, the local commit remains and you can retry with `git push`.
These tasks do not create Git tags or GitHub releases.
