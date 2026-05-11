{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkDiagnosticsPresetEnableOption;

  cfg = config.vim.diagnostics.presets.golangci-lint;
in {
  options.vim.diagnostics.presets.golangci-lint = {
    enable = mkDiagnosticsPresetEnableOption "golangci-lint" "GolangCI Lint";
  };

  config = mkIf cfg.enable {
    vim.diagnostics.nvim-lint.linters.golangci-lint = {
      cmd = getExe pkgs.golangci-lint;
      args = [
        "run"
        "--output.json.path=stdout"
        "--issues-exit-code=0"
        "--show-stats=false"
        "--fix=false"
        "--path-mode=abs"
        # Overwrite values that could be configured and result in unwanted writes
        "--output.text.path="
        "--output.tab.path="
        "--output.html.path="
        "--output.checkstyle.path="
        "--output.code-climate.path="
        "--output.junit-xml.path="
        "--output.teamcity.path="
        "--output.sarif.path="
      ];
      parser = mkLuaInline ''
        function(output, bufnr)
          local SOURCE = "golangci-lint";

          local function display_tool_error(msg)
            return{
              {
                bufnr = bufnr,
                lnum = 0,
                col = 0,
                message = string.format("[%s] %s", SOURCE, msg),
                severity = vim.diagnostic.severity.ERROR,
                source = SOURCE,
              },
            }
          end

          if output == "" then
            return display_tool_error("no output provided")
          end

          local ok, decoded = pcall(vim.json.decode, output)
          if not ok then
            return display_tool_error("failed to parse JSON output")
          end

          if not decoded or not decoded.Issues then
            return display_tool_error("unexpected output format")
          end

          local severity_map = {
            error   = vim.diagnostic.severity.ERROR,
            warning = vim.diagnostic.severity.WARN,
            info    = vim.diagnostic.severity.INFO,
            hint    = vim.diagnostic.severity.HINT,
          }
          local diagnostics = {}
          for _, issue in ipairs(decoded.Issues) do
            local sev = vim.diagnostic.severity.ERROR
            if issue.Severity and issue.Severity ~= "" then
              local normalized = issue.Severity:lower()
              sev = severity_map[normalized] or vim.diagnostic.severity.ERROR
            end
            table.insert(diagnostics, {
              bufnr = bufnr,
              lnum = issue.Pos.Line - 1,
              col = issue.Pos.Column - 1,
              message = issue.Text,
              code = issue.FromLinter,
              severity = sev,
              source = SOURCE,
            })
          end
          return diagnostics
        end
      '';
    };
  };
}
