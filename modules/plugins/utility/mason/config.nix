{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (pkgs) symlinkJoin;
  cfg = config.vim.utility.mason;
in {
  vim = mkIf cfg.enable {
    luaConfigRC.mason = ''
      vim.env.MASON = '${
        symlinkJoin {
          name = "mason-store";
          paths = cfg.packages;
        }
      }'
    '';
  };
}
