# =============================================================================
#  TEMPLATE: headless homelab server or VM — no desktop
#
#  Not built until you use it. For a new server or VM:
#    1. cp -r hosts/server-template hosts/<name>
#    2. Add it to flake.nix:  <name> = mkHost "<name>" ./hosts/<name>;
#    3. Install NixOS (README §7), then copy its
#       /etc/nixos/hardware-configuration.nix over the placeholder.
#    4. Fill in the SSH key below, `git add hosts/<name>`, then
#         nixos-rebuild boot --sudo --flake ~/nixos-config#<name>
#
#  Every feature is off unless it's set to true below; the desktop ones are
#  listed as false so the file shows the whole picture.
# =============================================================================
{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  my = {
    system = {
      user.enable = true; # your account
      nix.enable = true;
      systemTools.enable = true; # admin tools (incl. git, to clone this repo) + nix-ld
      boot = {
        enable = true;
        plymouth.enable = false; # plain boot text — useful on a console
      };
      # true if installed like the laptops (btrfs with home/nix subvolumes);
      # false for ext4 — common for VMs
      btrfs.enable = true;
      zram.enable = true;
      locale.enable = true;
      home-manager.enable = true; # your zsh, CLI tools and Neovim
      firmware.enable = true; # bare metal; false for a VM
      graphics.enable = false;
      hibernation.enable = false;
    };

    hardware = {
      bluetooth.enable = false;
      laptop.enable = false;
      # gpu = null; (no GPU driver)
    };

    networking = {
      networkmanager.enable = true; # `nmtui` for Wi-Fi/static IPs
      DNS-quad9.enable = true; # false if the server itself is your DNS (e.g. Pi-hole)
      firewall.enable = true;
      openssh = {
        enable = true;
        # TODO: your public key(s) — `cat ~/.ssh/id_ed25519.pub` on the
        # laptop/desktop. Evaluation stops until there is at least one.
        authorizedKeys = [
          # "ssh-ed25519 AAAAC3Nz… lucas@PrimaryLaptop"
        ];
      };
    };

    desktop = {
      hyprland.enable = false;
      noctalia.enable = false;
      greeter.enable = false;
      audio.enable = false;
      keyring.enable = false;
      theme.enable = false;
    };

    programs = {
      zsh.enable = true;
      cli.enable = true;
      neovim.enable = true;
      dev.enable = false; # true for your git email/config and the build toolchain
      apps.enable = false;
      gaming.enable = false;
    };

    virtualisation = {
      docker.enable = true; # self-hosted services in containers
      libvirt.enable = false; # true if this server hosts VMs itself
      vm-guest.enable = false; # true if this machine IS a VM (QEMU guest agent)
    };
  };

  # Servers: the LTS kernel instead of the latest mainline one
  boot.kernelPackages = pkgs.linuxPackages;

  # Containers start at boot (desktops start Docker on first use)
  virtualisation.docker.enableOnBoot = true;

  # Ports for services this machine hosts (SSH is opened by openssh):
  # networking.firewall.allowedTCPPorts = [ 80 443 ];

  # The NixOS release this machine was FIRST INSTALLED with — check with
  # `grep stateVersion /etc/nixos/configuration.nix` after install.
  system.stateVersion = "26.05";
}
