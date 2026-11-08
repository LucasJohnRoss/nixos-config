# PipeWire replaces PulseAudio/JACK (same as CachyOS), plus a mixer GUI
{ config, lib, ... }:
{
  options.my.desktop.audio.enable = lib.mkEnableOption "PipeWire audio";

  config = lib.mkIf config.my.desktop.audio.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    home-manager.sharedModules = [
      ({ pkgs, ... }: { home.packages = [ pkgs.pavucontrol ]; })
    ];
  };
}
