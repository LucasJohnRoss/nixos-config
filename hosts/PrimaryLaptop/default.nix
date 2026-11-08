{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  my = {
    system = {
      user.enable = true;
      nix.enable = true;
      systemTools.enable = true;
      boot = {
        enable = true;
        plymouth.enable = true;
      };
      btrfs.enable = true;
      zram.enable = true;
      locale.enable = true;
      home-manager.enable = true;
      firmware.enable = true;
      graphics.enable = true;

      hibernation = {
        enable = false;
        # resumeDevice = "/dev/mapper/luks-…";
        # resumeOffset = "…"; # sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
      };
    };

    hardware = {
      bluetooth.enable = true;
      laptop.enable = true;
      gpu = "intel";
    };

    networking = {
      networkmanager.enable = true;
      DNS-quad9.enable = true;
      firewall.enable = true;
      openssh.enable = false;
    };

    desktop = {
      hyprland.enable = true;
      noctalia.enable = true;
      greeter = {
        enable = true;
        autoLogin = true;
      };
      audio.enable = true;
      keyring.enable = true;
      theme.enable = true;
    };

    programs = {
      zsh.enable = true;
      cli.enable = true;
      neovim.enable = true;
      dev.enable = true;
      apps.enable = true;
      gaming.enable = false;
    };

    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
      vm-guest.enable = false;
    };
  };
  system.stateVersion = "26.05";
}
