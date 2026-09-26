{ self }:
{
  lib,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Home Manager already declares a full `programs.opencode` module with
  # settings, agents, commands, and theme options. Redeclaring it here would
  # collide, so this module only points that module at the flake's package.
  # Enable and configure opencode through Home Manager as usual.
  config.programs.opencode.package = lib.mkDefault self.packages.${system}.opencode;
}
