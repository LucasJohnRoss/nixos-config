# Hibernation to a btrfs swapfile
{ config, lib, ... }:
let
  cfg = config.my.system.hibernation;
in
{
  options.my.system.hibernation = {
    enable = lib.mkEnableOption "hibernation to a disk swapfile";

    swapfile = lib.mkOption {
      type = lib.types.str;
      default = "/swap/swapfile";
      description = "Path of the btrfs swapfile that holds the hibernation image.";
    };

    resumeDevice = lib.mkOption {
      type = lib.types.str;
      example = "/dev/mapper/luks-0d3a4560-b40f-49b0-b6a1-65c4918bba97";
      description = ''
        The block device that holds the btrfs filesystem. With LUKS this is the
        *unlocked* mapper device — copy the name from `ls /dev/mapper`.
      '';
    };

    resumeOffset = lib.mkOption {
      type = lib.types.str;
      example = "533760";
      description = "Output of: sudo btrfs inspect-internal map-swapfile -r /swap/swapfile";
    };
  };

  config = lib.mkIf cfg.enable {
    # Where the kernel looks for a hibernation image on boot
    boot.resumeDevice = cfg.resumeDevice;
    boot.kernelParams = [ "resume_offset=${cfg.resumeOffset}" ];

    # Disk swapfile on its own btrfs subvolume — required for hibernation
    # (systemd ignores zram for the hibernation image).
    swapDevices = [ { device = cfg.swapfile; } ];
  };
}
