# Secret Service keyring — Proton VPN and Brave store credentials here.
{ config, lib, ... }:
{
  options.my.desktop.keyring.enable = lib.mkEnableOption "the GNOME keyring and Seahorse";

  config = lib.mkIf config.my.desktop.keyring.enable {
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true; # Keyring GUI
  };
}
