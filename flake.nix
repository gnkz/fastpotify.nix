{
  description = "Nix package for Fastpotify";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;
      overlay = final: _prev: {
        fastpotify = final.callPackage ./package.nix { };
      };
    in
    {
      overlays.default = overlay;

      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          inherit (pkgs) fastpotify;
          default = pkgs.fastpotify;
        }
      );

      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
