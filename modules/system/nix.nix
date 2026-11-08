# Nix itself: flakes, store optimisation, unfree packages, nh — and AppImages
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.system.nix.enable = lib.mkEnableOption "flakes, unfree packages, nh and AppImage support";

  config = lib.mkIf config.my.system.nix.enable {
    nix.settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true; # hard-link identical files in /nix/store
      trusted-users = [ "root" ];
    };

    # Brave, Claude Code, Steam, the NVIDIA driver, etc. are unfree licences
    nixpkgs.config.allowUnfree = true;

    # `nh` — a friendlier front-end for nixos-rebuild that shows a package diff before switching, plus automatic garbage collection.
    programs.nh = {
      enable = true;
      flake = vars.flakeDir;
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 14d --keep 5";
      };
    };

    # Run AppImages directly (./Something.AppImage), like on Arch
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
