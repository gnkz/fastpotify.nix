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
