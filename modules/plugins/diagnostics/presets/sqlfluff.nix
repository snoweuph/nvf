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

  cfg = config.vim.diagnostics.presets.sqlfluff;
in {
  options.vim.diagnostics.presets.sqlfluff = {
    enable = mkDiagnosticsPresetEnableOption "sqlfluff" "SQLFluff";

    dialect = mkOption {
      type = str;
      default = "ansi";
      description = "SQL dialect to use for sqlfluff diagnostics";
    };
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.sqlfluff = {
      cmd = getExe pkgs.sqlfluff;
      args = ["lint" "--format=json" "--dialect=${cfg.dialect}"];
    };
  };
}
