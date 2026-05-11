{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) str;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.sqruff;
in {
  options.vim.diagnostics.presets.sqruff = {
    enable = mkDiagnosticsPresetEnableOption "sqruff" "Sqruff";

    dialect = mkOption {
      type = str;
      default = "ansi";
      description = "SQL dialect to use for sqruff diagnostics";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqruff = {
      cmd = getExe pkgs.sqruff;
      args = ["lint" "--format=json" "--dialect=${cfg.dialect}" "-"];
    };
  };
}
