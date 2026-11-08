# Look & feel: fonts, Bibata cursor, Adwaita-dark for GTK and Qt, dark colour scheme
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.desktop.theme.enable = lib.mkEnableOption "fonts, the cursor and the GTK/Qt theme";

  config = lib.mkIf config.my.desktop.theme.enable {
    my.internal.needsHome = [ "my.desktop.theme" ];

    # ---- Fonts (system-wide) ----------------------------------------------
    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome # general-purpose icon font (Noctalia ships its own icons)
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only # eza and starship icons
    ];

    programs.dconf.enable = true; # where GTK4/libadwaita read the colour scheme

    # ---- Cursor and themes (your user, Home Manager) ----------------------
    home-manager.sharedModules = [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.adwaita-icon-theme ];

          home.pointerCursor = {
            enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 24;
            gtk.enable = true;
            hyprcursor.enable = true; # also sets HYPRCURSOR_THEME/SIZE for Hyprland
          };

          gtk = {
            enable = true;
            theme = {
              name = "Adwaita-dark";
              package = pkgs.gnome-themes-extra;
            };
            iconTheme = {
              name = "Adwaita";
              package = pkgs.adwaita-icon-theme;
            };
          };
          qt = {
            enable = true;
            platformTheme.name = "adwaita";
            style.name = "adwaita-dark";
          };

          # Dark mode for GTK4/libadwaita apps and the portal (Brave, Electron apps)
          dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
        }
      )
    ];
  };
}
