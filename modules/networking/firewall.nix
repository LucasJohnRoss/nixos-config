# Firewall
{ config, lib, ... }:
{
  options.my.networking.firewall.enable = lib.mkEnableOption "the firewall with VPN-friendly reverse-path filtering";

  config = lib.mkIf config.my.networking.firewall.enable {
    networking.firewall = {
      enable = true;
      # Proton VPN (WireGuard) breaks with strict reverse-path filtering
      checkReversePath = "loose";
    };
  };
}
