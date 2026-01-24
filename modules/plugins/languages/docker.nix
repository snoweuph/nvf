{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (builtins) attrNames;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.docker;

  defaultServers = [ "docker-language-server" ];
  servers = {
    docker-language-server = {
      cmd = [
        (getExe' pkgs.docker-language-server "docker-language-server")
        "start"
        "--stdio"
      ];
      filetypes = [
        "dockerfile"
      ];
      root_markers = [ ".git" ];
    };
  };
in
{
  options.vim.languages.docker = {
    enable = mkEnableOption "Dockerfile and Docker Compose language support";

    treesitter = {
      enable = mkEnableOption "Dockerfile treesitter" // {
        default = config.vim.languages.enableTreesitter;
      };
      package = mkGrammarOption pkgs "dockerfile";
    };

    lsp = {
      enable = mkEnableOption "Docker LSP support" // {
        default = config.vim.lsp.enable;
      };

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Docker LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [ cfg.treesitter.package ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers = mapListToAttrs (name: {
        inherit name;
        value = servers.${name};
      }) cfg.lsp.servers;
    })
  ]);
}
