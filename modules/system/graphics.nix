# 3D acceleration (Mesa). The vendor driver on top is my.hardware.gpu.
{ config, lib, ... }:
{
  options.my.system.graphics.enable = lib.mkEnableOption "3D acceleration, including 32-bit";

  config = lib.mkIf config.my.system.graphics.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # needed by Wine, Steam and 32-bit apps
    };
  };
}
