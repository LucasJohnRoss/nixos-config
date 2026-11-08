# Device firmware blobs and firmware updates (fwupd)
{ config, lib, ... }:
{
  options.my.system.firmware.enable = lib.mkEnableOption "redistributable firmware and fwupd";

  config = lib.mkIf config.my.system.firmware.enable {
    hardware.enableRedistributableFirmware = true;
    services.fwupd.enable = true; # fwupdmgr refresh && fwupdmgr update
  };
}
