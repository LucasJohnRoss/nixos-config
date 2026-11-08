# Neovim + language servers
#
# Rule: every server enabled in lua/config/lsp_servers.lua needs its package
# here. The list below mirrors that file — enabled there = active here,
# commented there = commented here — so enabling a server means uncommenting
# it in both places, then `rebuild`.
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.programs.neovim.enable = lib.mkEnableOption "Neovim with its language servers";

  config = lib.mkIf config.my.programs.neovim.enable {
    my.internal.needsHome = [ "my.programs.neovim" ];

    # Your user (Home Manager)
    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        {
          xdg.configFile.nvim.source = config.lib.file.mkOutOfStoreSymlink "${vars.flakeDir}/dotfiles/nvim";

          programs.neovim = {
            enable = true;
            defaultEditor = true; # sets EDITOR and VISUAL to nvim
            viAlias = true;
            vimAlias = true;

            # Home Manager generates a small init.lua (it switches off the
            # Python, Node, Ruby and Perl providers, which your config doesn't
            # use). Sideloading passes it via the wrapper instead of writing
            # ~/.config/nvim/init.lua — which would overwrite your linked config.
            sideloadInitLua = true;

            extraPackages = with pkgs; [
              # ---- Enabled in lsp_servers.lua -------------------------  lspconfig name
              clang-tools # clangd (also clang-format)
              basedpyright # basedpyright
              rust-analyzer # rust_analyzer — needs cargo/rustc from the project's
              #   dev shell (direnv, README §10) or add them to dev.nix
              marksman # marksman
              terraform-ls # terraformls
              stylua # stylua — runs as a server (`stylua --lsp`) and formats Lua
              lua-language-server # lua_ls

              # ---- Commented out in lsp_servers.lua — uncomment both together ----
              # bash-language-server # bashls
              # shellcheck # bashls runs it for its diagnostics
              # yaml-language-server # yamlls
              # vscode-langservers-extracted # jsonls (also provides html, cssls, eslint)
              # (sqlls: its server, sql-language-server, isn't packaged in nixpkgs.
              #  Use the `sqls` server instead — package `sqls`, key `sqls = {}`.)

              # ---- Not in lsp_servers.lua yet — add the server there to use one ----
              # nixd # nixd — for editing this repo
              # ruff # ruff (Python lint + format)
              # typescript-language-server # ts_ls
              # taplo # taplo (TOML)
              # dockerfile-language-server # dockerls
              # docker-compose-language-service # docker_compose_language_service
              # ansible-language-server # ansiblels
              # helm-ls # helm_ls
              # gopls # gopls (Go)
              # Formatters/linters for conform.nvim's formatters_by_ft (formatting.lua):
              # nixfmt prettierd shfmt hadolint

              # ---- Plugin builds ---------------------------------------------------
              tree-sitter # CLI nvim-treesitter compiles parsers with (needs 0.26.1+)
            ];
          };
        }
      )
    ];
  };
}
