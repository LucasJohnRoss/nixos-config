# Bluetooth, managed from Noctalia's Bluetooth panel
{ config, lib, ... }:
{
  options.my.hardware.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf config.my.hardware.bluetooth.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };
}
