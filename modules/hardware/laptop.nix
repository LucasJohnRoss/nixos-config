# Laptop: power profiles, battery, lid & sleep
{ config, lib, ... }:
{
  options.my.hardware.laptop.enable = lib.mkEnableOption "laptop power profiles, battery reporting and lid handling";

  config = lib.mkIf config.my.hardware.laptop.enable {
    services.power-profiles-daemon.enable = true; # balanced / power-saver / performance
    services.upower.enable = true; # battery info for Noctalia's bar

    # Lid Closure Behaviour
    services.logind.settings.Login = {
      HandleLidSwitch =
        if config.my.system.hibernation.enable then "suspend-then-hibernate" else "suspend";
      HandleLidSwitchExternalPower = "suspend";
      HandleLidSwitchDocked = "ignore";
    };
    systemd.sleep.settings.Sleep.HibernateDelaySec = "1h";
  };
}
