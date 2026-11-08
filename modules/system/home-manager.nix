# Home Manager, running as a NixOS module
{
  config,
  lib,
  inputs,
  vars,
  ...
}:
let
  cfg = config.my.system.home-manager;
  needsHome = config.my.internal.needsHome;
in
{
  options.my = {
    system.home-manager.enable = lib.mkEnableOption "Home Manager for ${vars.username}";

    # Filled in by features that are set up through Home Manager, so a host that enables one without Home Manager gets an error, not a no-op.
    internal.needsHome = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      internal = true;
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.enable || needsHome == [ ];
          message = "${lib.concatStringsSep ", " needsHome} ${
            if lib.length needsHome == 1 then "is" else "are"
          } set up through Home Manager: also set my.system.home-manager.enable = true.";
        }
      ];
    }

    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = config.my.system.user.enable;
          message = "my.system.home-manager needs your account: set my.system.user.enable = true.";
        }
      ];

      home-manager = {
        useGlobalPkgs = true; # Share the system's nixpkgs (and allowUnfree)
        useUserPackages = true; # Install user packages into /etc/profiles
        backupFileExtension = "hm-backup"; # Rename clashing files instead of failing
        extraSpecialArgs = { inherit inputs vars; };

        users.${vars.username} = {
          home.username = vars.username;
          home.homeDirectory = lib.mkDefault "/home/${vars.username}";

          # Like system.stateVersion: the Home Manager release this machine started on.
          home.stateVersion = config.system.stateVersion;

          # XDG base directories: exports XDG_CONFIG_HOME & co. and keeps zsh's files in ~/.config/zsh rather than your home folder.
          xdg.enable = true;

          programs.home-manager.enable = true;
        };
      };
    })
  ];
}
