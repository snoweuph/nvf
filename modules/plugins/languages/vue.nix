{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.vue;

  defaultServers = ["vue-language-server"];
  servers = {
    vue-language-server = {
      enable = true;
      cmd = [(getExe pkgs.vue-language-server) "--stdio"];
      filetypes = ["vue"];
    };
  };

  defaultFormat = ["biome" "biome-check" "biome-organize-imports"];
  formats = {
    biome = {
      command = getExe pkgs.biome;
    };

    biome-check = {
      command = getExe pkgs.biome;
    };

    biome-organize-imports = {
      command = getExe pkgs.biome;
    };
  };

  defaultDiagnosticsProvider = ["biomejs"];
  diagnosticsProviders = {
    biomejs = let
      pkg = pkgs.biome;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
      };
    };
  };
in {
  options.vim.languages.vue = {
    enable = mkEnableOption "Vue language support";

    treesitter = {
      enable =
        mkEnableOption "Vue treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      package = mkGrammarOption pkgs "vue";
    };

    lsp = {
      enable =
        mkEnableOption "Vue LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Vue LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Vue formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
        description = "TOML formatter to use.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Vue diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };

      types = diagnostics {
        langDesc = "Vue";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.vue = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.vue = cfg.extraDiagnostics.types;
        linters = mkMerge (
          map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types
        );
      };
    })
  ]);
}
