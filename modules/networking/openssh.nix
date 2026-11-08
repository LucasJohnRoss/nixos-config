# SSH server: key-only logins, no root login. Opens port 22.
{
  config,
  lib,
  vars,
  ...
}:
let
  cfg = config.my.networking.openssh;
in
{
  options.my.networking.openssh = {
    enable = lib.mkEnableOption "the OpenSSH server (key-only logins)";

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "ssh-ed25519 AAAAC3Nz… lucas@PrimaryLaptop" ];
      description = "Public keys allowed to log in as ${vars.username}.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # Password logins are off, so with no key nobody could log in over SSH
        assertion = cfg.authorizedKeys != [ ];
        message = "my.networking.openssh: add at least one key to my.networking.openssh.authorizedKeys.";
      }
    ];

    services.openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    users.users.${vars.username}.openssh.authorizedKeys.keys = lib.mkIf config.my.system.user.enable cfg.authorizedKeys;
  };
}
