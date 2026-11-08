# NetworkManager — used by Noctalia's network panel, nm-connection-editor, Proton VPN, and `nmtui` on servers
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.networking.networkmanager.enable = lib.mkEnableOption "NetworkManager";

  config = lib.mkIf config.my.networking.networkmanager.enable {
    networking.networkmanager.enable = true;

    # manage Wi-Fi without sudo
    users.users.${vars.username}.extraGroups = lib.mkIf config.my.system.user.enable [ "networkmanager" ];
  };
}
