# GPU drivers, early KMS (sharp LUKS prompt in Plymouth) and video acceleration
#
#   my.hardware.gpu = "intel";         Intel Broadwell (2014) and newer — iHD VA-API driver
#   my.hardware.gpu = "intel-legacy";  older Intel — i965 VA-API driver
#   my.hardware.gpu = "amd";           AMD (Mesa is already the default; adds early KMS)
#   my.hardware.gpu = "nvidia";        NVIDIA proprietary driver (see the notes below)
#   my.hardware.gpu = null;            off: generic modesetting only (the default)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  gpu = config.my.hardware.gpu;
in
{
  options.my.hardware = {
    gpu = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "intel"
          "intel-legacy"
          "amd"
          "nvidia"
        ]
      );
      default = null;
      description = "Which GPU driver stack this host uses (null = none).";
    };

    nvidia.branch = lib.mkOption {
      type = lib.types.str;
      default = "legacy_580";
      description = "hardware.nvidia.branch to use when my.hardware.gpu = \"nvidia\".";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (gpu != null) {
      assertions = [
        {
          assertion = config.my.system.graphics.enable;
          message = "my.hardware.gpu needs my.system.graphics.enable = true.";
        }
      ];
    })

    (lib.mkIf (gpu == "intel") {
      boot.initrd.kernelModules = [ "i915" ];
      hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
    })

    (lib.mkIf (gpu == "intel-legacy") {
      boot.initrd.kernelModules = [ "i915" ];
      hardware.graphics.extraPackages = [ pkgs.intel-vaapi-driver ];
    })

    (lib.mkIf (gpu == "amd") {
      boot.initrd.kernelModules = [ "amdgpu" ];
    })

    (lib.mkIf (gpu == "nvidia") {
      services.xserver.videoDrivers = [ "nvidia" ]; # loads the driver (no X server is started)

      hardware.nvidia = {
        branch = config.my.hardware.nvidia.branch;
        open = lib.mkDefault false; # closed modules — required for Pascal
        modesetting.enable = true; # required for Wayland/Hyprland

        # Saves VRAM to disk before suspend/hibernate and restores it after,
        # via the nvidia-suspend/-hibernate/-resume services. Without it, apps
        # (and Hyprland itself) come back with corrupted or black surfaces.
        powerManagement.enable = true;

        nvidiaSettings = true; # the nvidia-settings GUI
        # videoAcceleration (nvidia-vaapi-driver) is on by default
      };

      # The VRAM image is written to this directory during suspend/hibernate.
      # /var/tmp is on disk; a tmpfs /tmp could run out of room for 6 GB.
      hardware.nvidia.moduleParams.nvidia.NVreg_TemporaryFilePath = "/var/tmp";

      # Early KMS: load the driver in the initrd so Plymouth and the LUKS
      # prompt run at native resolution. (nvidia_uvm is deliberately left
      # out; the NixOS module loads it later, once the device is ready.)
      boot.initrd.kernelModules = [
        "nvidia"
        "nvidia_modeset"
        "nvidia_drm"
      ];

      # What Hyprland's NVIDIA page recommends for the session
      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia"; # VA-API through nvidia-vaapi-driver
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct"; # nvidia-vaapi-driver backend
      };
    })
  ];
}
