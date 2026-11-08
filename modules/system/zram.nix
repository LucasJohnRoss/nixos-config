# Compressed RAM swap used first for everyday swapping; Hibernation skips zram and uses the disk swapfile (hibernation.nix).
{ config, lib, ... }:
{
  options.my.system.zram.enable = lib.mkEnableOption "zram swap";

  config = lib.mkIf config.my.system.zram.enable {
    zramSwap = {
      enable = true;
      memoryPercent = 50;
    };
  };
}
