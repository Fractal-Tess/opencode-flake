{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  package = self.packages.${system}.opencode;
  cfg = config.programs.opencode;
in
{
  options = import ./options.nix { inherit lib package; };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
