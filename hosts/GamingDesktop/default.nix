{ pkgs, ... }:
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
        enable = true;
        resumeDevice = "/dev/mapper/luks-8a160b50-bda6-4fe3-b373-30688c8481dc";
        resumeOffset = "7087360"; # sudo btrfs inspect-internal map-swapfile -r /swap/swapfile
      };
    };

    hardware = {
      bluetooth.enable = true;
      laptop.enable = false;
      gpu = "nvidia";
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
      gaming.enable = true;
    };

    virtualisation = {
      docker.enable = true;
      libvirt.enable = true;
      vm-guest.enable = false;
    };
  };

  # If a kernel update breaks the NVIDIA 580 driver build, pin the LTS kernel
  # here until the driver catches up:
  # boot.kernelPackages = pkgs.linuxPackages;

  # ---------------------------------------------------------------------------
  # SECOND DRIVE — LUKS + btrfs, unlocked at boot with a key file kept on the
  # (already encrypted) system drive, so there is still only one passphrase
  # prompt. One-time setup after install (replace /dev/sdX — check `lsblk`;
  # the drive is erased):
  #
  #   sudo mkdir -p /etc/secrets && sudo chmod 700 /etc/secrets
  #   sudo dd if=/dev/urandom of=/etc/secrets/data.key bs=512 count=8
  #   sudo chmod 400 /etc/secrets/data.key
  #   sudo cryptsetup luksFormat --type luks2 /dev/sdX
  #   sudo cryptsetup luksAddKey /dev/sdX /etc/secrets/data.key
  #   sudo cryptsetup open /dev/sdX data --key-file /etc/secrets/data.key
  #   sudo mkfs.btrfs -L data /dev/mapper/data
  #   sudo blkid -s UUID -o value /dev/sdX     # the LUKS UUID for crypttab below
  #
  # Then uncomment, fill in the UUID, `git add`, rebuild.
  # (luksFormat asks for a passphrase too — keep it as a recovery key.)
  # ---------------------------------------------------------------------------
  environment.etc.crypttab.text = ''
    data UUID=1a263bb4-3f6e-451a-b199-ab8fa1735aae /etc/secrets/data.key luks,nofail
  '';
  fileSystems."/data" = {
    device = "/dev/mapper/data";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "nofail" # boot carries on if the drive is missing or fails to unlock
    ];
  };
  services.btrfs.autoScrub.fileSystems = [ "/data" ];

  system.stateVersion = "26.05";
}
