# Boot loader and kernel: Limine (UEFI), latest mainline kernel
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.my.system.boot.enable = lib.mkEnableOption "the Limine boot loader and latest kernel";

  config = lib.mkIf config.my.system.boot.enable {
    boot = {
      loader = {
        limine = {
          enable = true;
          efiSupport = true;
          maxGenerations = 10; # Number of generations that appear in the boot menu
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };

      # Latest mainline kernel. mkDefault so a host can pin another one,
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    };
  };
}
