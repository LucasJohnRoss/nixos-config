# Desktop Applications
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
{
  options.my.programs.apps.enable = lib.mkEnableOption "your desktop applications, Ghostty, Thunar, OBS and USB automounting";

  config = lib.mkIf config.my.programs.apps.enable {
    my.internal.needsHome = [ "my.programs.apps" ];

    # ---- Thunar (system parts) ------------------------------------------------
    programs.thunar = {
      enable = true;
      plugins = [
        (pkgs.thunar-archive-plugin or pkgs.xfce.thunar-archive-plugin) # right-click extract/compress
        (pkgs.thunar-volman or pkgs.xfce.thunar-volman) # removable media handling
      ];
    };
    programs.xfconf.enable = true; # lets Thunar save its preferences outside XFCE
    services.gvfs.enable = true; # trash, network shares, MTP phones in Thunar
    services.tumbler.enable = true; # thumbnails in Thunar

    # ---- OBS virtual camera ---------------------------------------------------
    # Only the v4l2loopback kernel module is set up here (`package = null`
    # installs no OBS). OBS itself comes from Home Manager below.
    programs.obs-studio = {
      enable = true;
      package = null;
      enableVirtualCamera = true;
    };

    # ---- USB automounting -----------------------------------------------------
    services.udisks2.enable = true; # Backend for udiskie (below)

    # Your user (Home Manager)
    home-manager.sharedModules = [
      (
        { config, pkgs, ... }:
        {
          home.packages = with pkgs; [
            # ---- Terminal -----------------------------------------------------
            ghostty

            # ---- Files --------------------------------------------------------
            file-roller # Archive backend for Thunar's right-click extract

            # ---- Windows compatibility ----------------------------------------
            wineWow64Packages.stable # 32- and 64-bit Windows apps
            winetricks

            # ---- Applications -------------------------------------------------
            mission-center
            gnome-calculator
            libreoffice
            hunspell
            hunspellDicts.en_GB-ise # LibreOffice British English spell-check
            (pkgs.brave-origin or pkgs.brave) # Uses unstable branch, fallsback to stable if necessary
            proton-vpn
            bitwarden-desktop
            notion-electron
            qbittorrent
            vlc
          ];

          home.sessionVariables.TERMINAL = "ghostty"; # Sets default terminal
          xdg.configFile.ghostty.source = config.lib.file.mkOutOfStoreSymlink "${vars.flakeDir}/dotfiles/ghostty";

          # OBS Studio (its virtual camera module is set up above)
          programs.obs-studio.enable = true;

          # USB drives: automounted by udiskie, a systemd user service started with the UWSM session
          services.udiskie = {
            enable = true;
            automount = true;
            notify = true;
            tray = "auto"; # Widget to appear in tray
          };
        }
      )
    ];
  };
}
