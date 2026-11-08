# Development: git, a "base-devel" equivalent and languages
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.programs.dev.enable = lib.mkEnableOption "git, a global build toolchain, Python, Node and Claude Code";

  config = lib.mkIf config.my.programs.dev.enable {
    my.internal.needsHome = [ "my.programs.dev" ];

    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        {
          # ---- git ------------------------------------------------------------
          programs.git = {
            enable = true;
            settings = {
              user.email = "lucasross72@outlook.com";
              user.name = vars.username;
              init.defaultBranch = "main";
              pull.rebase = true;
            };
          };

          # ---- Toolchain and languages ---------------------------------------
          home.packages = with pkgs; [
            gcc # also used by Neovim: treesitter parsers, telescope-fzf-native, LuaSnip's jsregexp
            gnumake # also used by Neovim: telescope-fzf-native, LuaSnip's jsregexp
            binutils
            pkg-config
            autoconf
            automake
            libtool
            cmake
            patch
            (python3.withPackages (
              ps: with ps; [
                pip
                virtualenv
              ]
            ))
            uv # fast Python project/venv manager — recommended over global pip on NixOS
            nodejs # provides node + npm
            claude-code # Claude Code CLI
          ];

          # Global npm installs (`npm i -g`) go to ~/.npm-global, because
          # /nix/store is read-only.
          home.file.".npmrc".text = ''
            prefix=${config.home.homeDirectory}/.npm-global
          '';
          home.sessionPath = lib.mkAfter [ "$HOME/.npm-global/bin" ];
        }
      )
    ];
  };
}
