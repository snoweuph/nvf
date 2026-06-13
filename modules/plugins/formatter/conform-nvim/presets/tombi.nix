{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.tombi;
in {
  options.vim.formatter.conform-nvim.presets.tombi = {
    enable = mkFormatterPresetEnableOption {
      option = "tombi";
      display = "Tombi";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.tombi = {
      command = getExe pkgs.tombi;
      args = [
        "format"
        "--stdin-filepath"
        "$FILENAME"
        "-"
      ];
    };
  };
}
