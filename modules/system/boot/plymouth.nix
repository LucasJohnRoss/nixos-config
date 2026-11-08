# Boot splash and quiet boot (the LUKS prompt appears inside the splash)
{ config, lib, ... }:
{
  options.my.system.boot.plymouth.enable = lib.mkEnableOption "the Plymouth splash and quiet boot";

  config = lib.mkIf config.my.system.boot.plymouth.enable {
    boot = {
      plymouth.enable = true;

      # Hide kernel/systemd text so the splash isn't interrupted
      # (the Plymouth module adds "splash" itself)
      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "boot.shell_on_fail"
        "udev.log_priority=3"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}
