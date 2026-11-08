# Gaming: Steam, gamemode, Discord, MangoHud
{ config, lib, ... }:
{
  options.my.programs.gaming.enable = lib.mkEnableOption "Steam, gamemode, Discord and MangoHud";

  config = lib.mkIf config.my.programs.gaming.enable {
    my.internal.needsHome = [ "my.programs.gaming" ];

    assertions = [
      {
        assertion = config.my.system.graphics.enable;
        message = "my.programs.gaming needs 32-bit graphics: set my.system.graphics.enable = true.";
      }
    ];

    # Steam needs system-level setup: 32-bit graphics, udev rules for controllers and the Steam Deck, and firewall ports.
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true; # Steam Remote Play / Steam Link
      localNetworkGameTransfers.openFirewall = true; # copy games between PCs on the LAN
    };

    # Feral GameMode: CPU governor/priority boost while a game runs.
    # In Steam: Properties → Launch options → `gamemoderun %command%`
    programs.gamemode.enable = true;

    home-manager.sharedModules = [
      (
        { pkgs, ... }:
        {
          home.packages = with pkgs; [
            discord
          ];

          programs.mangohud.enable = true;
        }
      )
    ];
  };
}
