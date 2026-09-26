{ lib, package }:
{
  programs.opencode = {
    enable = lib.mkEnableOption "opencode, an AI coding agent built for the terminal";

    package = lib.mkOption {
      type = lib.types.package;
      default = package;
      description = "opencode package to install.";
    };
  };
}
