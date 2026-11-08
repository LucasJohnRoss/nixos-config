# Hyprland (under UWSM), portals and desktop plumbing, plus your hyprland.lua
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  networkmanager = config.my.networking.networkmanager.enable;
in
{
  options.my.desktop.hyprland.enable = lib.mkEnableOption "Hyprland under UWSM";

  config = lib.mkIf config.my.desktop.hyprland.enable {
    my.internal.needsHome = [ "my.desktop.hyprland" ];

    programs.hyprland = {
      enable = true;
      # UWSM wraps Hyprland in a proper systemd user session: graphical-session
      # target, XDG autostart, clean logout. Shown as "Hyprland (UWSM)" in the greeter.
      withUWSM = true;
      xwayland.enable = true;
    };
    # The Hyprland module already adds xdg-desktop-portal-hyprland.
    # The GTK portal adds file pickers / settings for GTK & Electron apps.
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    # Electron/Chromium apps (Brave, Notion, Claude...) use native Wayland
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Noctalia registers its own polkit agent (`polkit_agent = true` in config.toml)
    security.polkit.enable = true;
    programs.dconf.enable = true; # GTK settings storage (also used by virt-manager)

    # Your user (Home Manager)
    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        {
          # ~/.config/hypr -> dotfiles/hypr (hyprland.lua + monitors/, picked by
          # hostname). An out-of-store link: edits apply on save, no rebuild.
          xdg.configFile.hypr.source = config.lib.file.mkOutOfStoreSymlink "${vars.flakeDir}/dotfiles/hypr";

          # (Noctalia replaces hyprpaper, hyprshot, waybar, rofi, dunst,
          # hyprlock, hypridle, hyprpolkitagent and cliphist.)
          home.packages =
            with pkgs;
            [
              libnotify # notify-send (Noctalia is the notification daemon that shows them)
              wl-clipboard # wl-copy / wl-paste in scripts and the terminal
              brightnessctl # backlight keys in hyprland.lua — works without the `video` group via logind
            ]
            # nm-connection-editor (Noctalia's network panel covers day-to-day Wi-Fi)
            ++ lib.optional networkmanager networkmanagerapplet;
        }
      )
    ];
  };
}
