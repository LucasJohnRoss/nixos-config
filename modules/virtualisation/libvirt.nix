# KVM/QEMU/libvirt, plus virt-manager on hosts with a desktop
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.my.virtualisation.libvirt;
in
{
  options.my.virtualisation.libvirt.enable = lib.mkEnableOption "KVM/QEMU virtual machines through libvirt";

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm; # host-arch QEMU only (smaller than full qemu)
        runAsRoot = false;
        swtpm.enable = true; # virtual TPM (Windows 11 guests)
        # UEFI (OVMF) firmware images are included by default.
      };
    };
    virtualisation.spiceUSBRedirection.enable = true; # pass USB devices into VMs

    users.users.${vars.username}.extraGroups = lib.mkIf config.my.system.user.enable [
      "libvirtd" # virt-manager/virsh on qemu:///system without a password prompt
      "kvm"
    ];

    # Your user (Home Manager): the virt-manager GUI — only on hosts with a desktop
    home-manager.sharedModules = lib.mkIf config.my.desktop.hyprland.enable [
      (
        { pkgs, ... }:
        {
          home.packages = [ pkgs.virt-manager ];

          # virt-manager connects to the system libvirt daemon automatically
          dconf.settings."org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        }
      )
    ];
  };
}
