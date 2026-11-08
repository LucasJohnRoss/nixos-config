# DNS: Quad9 over TLS through systemd-resolved
{ config, lib, ... }:
{
  options.my.networking.DNS-quad9.enable = lib.mkEnableOption "Quad9 DNS over TLS via systemd-resolved";

  config = lib.mkIf config.my.networking.DNS-quad9.enable {
    # NetworkManager (if enabled) hands DNS to resolved
    networking.networkmanager.dns = "systemd-resolved";

    networking.nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
    ];

    services.resolved = {
      enable = true;
      settings.Resolve = {
        # "~." makes Quad9 the preferred resolver for ALL domains, so the router's DHCP-supplied DNS isn't used instead.
        Domains = [ "~." ];
        # Encrypt to Quad9 when possible. "true" enforces it but breaks hotel / café captive portals, so opportunistic is the default.
        DNSOverTLS = "opportunistic";
        # Don't fall back to systemd's built-in Cloudflare/Google list
        FallbackDNS = [
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
        ];
      };
    };
  };
}
