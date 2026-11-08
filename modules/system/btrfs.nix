# btrfs mount options and scrubbing
{ config, lib, ... }:
{
  options.my.system.btrfs.enable = lib.mkEnableOption "btrfs mount options and monthly scrub";

  config = lib.mkIf config.my.system.btrfs.enable {
    boot.supportedFilesystems = [ "btrfs" ];

    # These lists merge with the `subvol=` options in each host's hardware-configuration.nix.
    fileSystems = {
      "/".options = [
        "compress=zstd"
        "noatime"
      ];
      "/home".options = [
        "compress=zstd"
        "noatime"
      ];
      "/nix".options = [
        "compress=zstd"
        "noatime"
      ];
    };

    # Monthly integrity check of btrfs data/metadata checksums.
    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
      fileSystems = [ "/" ];
    };
  };
}
