{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) listOf package;
in {
  options.vim.utility.mason = {
    enable = mkEnableOption ''
      a mock implementation of Mason.

      ::: {.note}
      This is intended to support plugins that rely on resolving asset paths within the Mason directory structure.
      :::
    '';
    packages = mkOption {
      description = "packages to be added to the Mason store";
      default = [];
      type = listOf package;
    };
  };
}
