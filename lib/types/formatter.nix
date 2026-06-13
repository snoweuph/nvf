{lib}: let
  inherit (lib.options) mkEnableOption;

  mkFormatterPresetEnableOption = {
    option,
    display,
    extra ? "",
  }:
    mkEnableOption ''
      The ${display} formatter.

      ${extra}

      Use {option}`vim.formatter.conform-nvim.presets.${option}` for customization
    '';
in {
  inherit mkFormatterPresetEnableOption;
}
