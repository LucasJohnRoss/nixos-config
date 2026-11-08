# Running AS a virtual machine (KVM/QEMU, Proxmox, libvirt): the QEMU guest agent, so the hypervisor can shut the VM down cleanly, freeze filesystems for snapshots and show its IP address.
{ config, lib, ... }:
{
  options.my.virtualisation.vm-guest.enable = lib.mkEnableOption "the QEMU guest agent, for hosts that are VMs";

  config = lib.mkIf config.my.virtualisation.vm-guest.enable {
    services.qemuGuest.enable = true;
  };
}
