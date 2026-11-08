# System tools: rescue/admin commands for root, and nix-ld for pre-built binaries
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.system.systemTools.enable = lib.mkEnableOption "system-wide admin tools and nix-ld";

  config = lib.mkIf config.my.system.systemTools.enable {
    # Rescue/admin tools — available to root and in a TTY even if user environment is broken
    environment.systemPackages = with pkgs; [
      curl
      wget
      git
      vim
      pciutils # lspci
      usbutils # lsusb
      btrfs-progs
      cryptsetup
      sbctl # Secure Boot keys for Limine later - TODO
    ];

    programs.nix-ld = {
      enable = true;
      # Libraries binaries can find when run using nix-ld.
      libraries = with pkgs; [
        # Common extras — uncomment what you need:
        # glib # libglib/libgobject — many GUI and Electron binaries
        # libGL # OpenGL
        # libxkbcommon # keyboard handling in GUI binaries
        # libx11 # X11 apps under XWayland
        # nss # Chromium/Electron-based binaries
        # nspr
        # alsa-lib # audio
        # fontconfig
        # freetype
        # dbus
        # icu # .NET binaries
        # libffi # some Python wheels
      ];
    };
  };
}
