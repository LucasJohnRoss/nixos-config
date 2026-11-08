# Terminal & CLI tools
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.programs.cli.enable = lib.mkEnableOption "the CLI toolset (tmux, btop, yazi, fzf, eza, bat, direnv…)";

  config = lib.mkIf config.my.programs.cli.enable {
    my.internal.needsHome = [ "my.programs.cli" ];

    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        let
          link = name: {
            source = config.lib.file.mkOutOfStoreSymlink "${vars.flakeDir}/dotfiles/${name}";
          };
        in
        {
          home.packages = with pkgs; [
            tmux
            btop
            ripgrep
            fd
            tree-sitter # the tree-sitter CLI for nvim-treesitter
            unzip
            jq
          ];

          xdg.configFile = lib.genAttrs [
            "yazi"
            "btop"
            "tmux"
          ] link;

          # Yazi
          programs.yazi = {
            enable = true;
            enableZshIntegration = true;
          };

          # zoxide (`z dir`) — also used by Yazi's jump plugin
          programs.zoxide = {
            enable = true;
            enableZshIntegration = true;
          };

          # fzf: installs it and adds the zsh keybindings —
          # Ctrl-R fuzzy history, Ctrl-T insert file path, Alt-C cd into directory
          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
            defaultCommand = "fd --type f --hidden --exclude .git"; # respect .gitignore, include dotfiles
            fileWidget.command = "fd --type f --hidden --exclude .git"; # Ctrl-T
            changeDirWidget.command = "fd --type d --hidden --exclude .git"; # Alt-C
          };

          # bat: `cat` with syntax highlighting and git markers
          programs.bat = {
            enable = true;
            config = {
              theme = "TwoDark";
              style = "numbers,changes,header";
            };
          };

          # eza
          programs.eza = {
            enable = true;
            enableZshIntegration = true;
            icons = "always";
            colors = "always";
            git = true; # Git status column in long listings
            extraOptions = [ "--group-directories-first" ];
          };

          # direnv + nix-direnv: entering a folder with an .envrc loads its dev environment, leaving unloads it.
          programs.direnv = {
            enable = true;
            enableZshIntegration = true;
            nix-direnv.enable = true;
            config.global.hide_env_diff = true; # skip the long "+VAR -VAR" list on every cd
          };
        }
      )
    ];
  };
}
