# Noctalia shell
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.desktop.noctalia.enable = lib.mkEnableOption "the Noctalia shell";

  config = lib.mkIf config.my.desktop.noctalia.enable {
    my.internal.needsHome = [ "my.desktop.noctalia" ];

    assertions = [
      {
        assertion = config.my.desktop.hyprland.enable;
        message = "my.desktop.noctalia runs inside Hyprland: also set my.desktop.hyprland.enable = true.";
      }
    ];

    programs.noctalia = {
      enable = true;
      # Run it as a systemd user service tied to graphical-session.target,
      systemd.enable = true;
    };

    # Your user (Home Manager): ~/.config/noctalia -> dotfiles/noctalia (config.toml)
    home-manager.sharedModules = [
      (
        { config, ... }:
        {
          xdg.configFile.noctalia.source = config.lib.file.mkOutOfStoreSymlink "${vars.flakeDir}/dotfiles/noctalia";
        }
      )
    ];
  };
}
