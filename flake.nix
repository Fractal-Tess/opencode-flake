{
  description = "opencode packaged for Nix";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      packageFor = system: nixpkgs.legacyPackages.${system}.callPackage ./packages/opencode.nix { };
    in
    {
      packages = forAllSystems (
        system:
        let
          opencode = packageFor system;
        in
        {
          inherit opencode;
          default = opencode;
        }
      );

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.opencode}/bin/opencode";
          meta.description = "Run opencode";
        };
      });

      checks = forAllSystems (system: {
        opencode = self.packages.${system}.opencode;
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);

      overlays.default = final: _previous: {
        opencode = final.callPackage ./packages/opencode.nix { };
      };

      nixosModules.default = import ./modules/nixos.nix { inherit self; };
      homeManagerModules.default = import ./modules/home-manager.nix { inherit self; };
    };
}
