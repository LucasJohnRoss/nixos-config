# zsh as your login shell (your old .zshrc without oh-my-zsh) + starship prompt
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  dotfiles = "${vars.flakeDir}/dotfiles";
  cli = config.my.programs.cli.enable;
in
{
  options.my.programs.zsh.enable = lib.mkEnableOption "zsh as the login shell, with starship";

  config = lib.mkIf config.my.programs.zsh.enable {
    my.internal.needsHome = [ "my.programs.zsh" ];

    # Must be enabled system-wide for zsh to be a valid login shell
    programs.zsh.enable = true;
    # Home Manager runs compinit itself; skipping the system-wide one avoids
    # running it twice (a slower shell start)
    programs.zsh.enableGlobalCompInit = false;
    # Expose completions shipped by system packages (e.g. systemctl, nix) to zsh
    environment.pathsToLink = [ "/share/zsh" ];

    users.users.${vars.username}.shell = lib.mkIf config.my.system.user.enable pkgs.zsh;

    # Your user (Home Manager): the .zshrc itself
    home-manager.sharedModules = [
      (
        { config, ... }:
        {
          home.sessionPath = [
            "$HOME/bin" # from your old .zshrc
            "$HOME/.local/bin" # where `pip install --user` / uv tools go
          ];

          # Starship prompt (replaces `eval "$(starship init zsh)"`). Its config
          # is your own ~/.config/starship.toml, linked from dotfiles/.
          programs.starship = {
            enable = true;
            enableZshIntegration = true;
          };
          xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/starship.toml";

          # (completion menu, key bindings, history and directory options) are
          # set explicitly below, as are your eza/bat aliases.
          programs.zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true; # was the zsh-autosuggestions plugin
            syntaxHighlighting.enable = true; # was the zsh-syntax-highlighting plugin
            defaultKeymap = "emacs"; # oh-my-zsh's default (bindkey -e)
            autocd = true; # type a directory name to cd into it (oh-my-zsh default)

            history = {
              size = 50000;
              save = 50000;
              path = "${config.xdg.dataHome}/zsh/history";
              ignoreDups = true;
              ignoreSpace = true; # a command starting with a space isn't saved
              expireDuplicatesFirst = true;
              extended = true; # save timestamps
              share = true;
            };

            # Other oh-my-zsh defaults
            setOptions = [
              "AUTO_PUSHD" # cd pushes onto the directory stack (`cd -<Tab>` to pick one)
              "PUSHD_IGNORE_DUPS"
              "PUSHD_MINUS"
              "HIST_VERIFY" # show !! / !$ expansions before running them
              "INTERACTIVE_COMMENTS" # allow # comments on the command line
              "LONG_LIST_JOBS"
              "COMPLETE_IN_WORD"
              "ALWAYS_TO_END"
              "AUTO_MENU"
            ];

            shellAliases = {
              # NixOS workflow — nh picks this machine's host config by hostname
              rebuild = "nh os switch"; # apply config changes
              update = "nh os switch --update"; # update flake inputs + apply (≈ pacman -Syu)
              rebuild-test = "nh os test"; # apply until next reboot only
              cleanup = "nh clean all --keep 5";

              md = "mkdir -p"; # oh-my-zsh
              "-" = "cd -"; # oh-my-zsh: `-` jumps back to the previous directory
              # vi / vim → nvim come from neovim.nix (viAlias / vimAlias)
            }
            // lib.optionalAttrs cli {
              # Your eza aliases (the shared flags — icons, colour, directories
              # first — are set once in programs.eza in cli.nix)
              ls = "eza -a";
              ll = "eza -alh --total-size";
              lt = "eza -aT";
              cat = "bat --paging=never"; # plain `bat` still pages long files
            };

            # oh-my-zsh: `cd ...` = cd ../.., `cd ....` = cd ../../..
            shellGlobalAliases = {
              "..." = "../..";
              "...." = "../../..";
              "....." = "../../../..";
            };

            initContent = lib.mkMerge [
              # General configuration: after compinit, plugins and the tool
              # integrations (yazi's `y`, starship, direnv — order 1000), so
              # your key bindings win over anything they set; before aliases.
              (lib.mkOrder 1001 ''
                # ---- Completion (oh-my-zsh defaults) ----------------------------------
                zmodload -i zsh/complist
                unsetopt menu_complete flowcontrol
                zstyle ':completion:*:*:*:*:*' menu select
                # case-insensitive, then partial-word and substring matching
                zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
                zstyle ':completion:*' special-dirs true
                zstyle ':completion:*' list-colors ""
                zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
                zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
                zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
                zstyle ':completion:*' use-cache yes
                zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/zcompcache"

                # ---- Key bindings -----------------------------------------------------
                # Word-wise movement and deletion stop at / . - _ (oh-my-zsh's WORDCHARS)
                WORDCHARS=""
                # Your bindings
                bindkey '^H' backward-kill-word          # Ctrl+Backspace
                bindkey '^[[8;6u' kill-whole-line        # Ctrl+Shift+Backspace
                # Up/Down search history for lines starting with what you've typed
                autoload -U up-line-or-beginning-search down-line-or-beginning-search
                zle -N up-line-or-beginning-search
                zle -N down-line-or-beginning-search
                bindkey '^[[A' up-line-or-beginning-search
                bindkey '^[OA' up-line-or-beginning-search
                bindkey '^[[B' down-line-or-beginning-search
                bindkey '^[OB' down-line-or-beginning-search
                # Home / End / Delete / Ctrl+Delete / Ctrl+←→ / Shift+Tab
                bindkey '^[[H' beginning-of-line
                bindkey '^[OH' beginning-of-line
                bindkey '^[[F' end-of-line
                bindkey '^[OF' end-of-line
                bindkey '^[[3~' delete-char
                bindkey '^[[3;5~' kill-word
                bindkey '^[[1;5C' forward-word
                bindkey '^[[1;5D' backward-word
                bindkey '^[[Z' reverse-menu-complete
                # Ctrl+X Ctrl+E edits the current command in $EDITOR (nvim)
                autoload -U edit-command-line
                zle -N edit-command-line
                bindkey '^X^E' edit-command-line
              '')

              # Last: anything that must see the aliases above
              (lib.mkAfter ''
                # Your cd: change directory, then list it (uses the eza `ls` alias)
                cd() {
                  builtin cd "$@" && ls
                }

                # Extra personal config (functions, local tweaks) — optional file
                [[ -f "${dotfiles}/zsh/personal.zsh" ]] && source "${dotfiles}/zsh/personal.zsh"
              '')
            ];
          };
        }
      )
    ];
  };
}
