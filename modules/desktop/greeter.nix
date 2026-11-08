# Login screen: Noctalia Greeter plus autologin
{
  config,
  lib,
  pkgs,
  vars,
  ...
}:
let
  cfg = config.my.desktop.greeter;
in
{
  options.my.desktop.greeter = {
    enable = lib.mkEnableOption "the Noctalia Greeter login screen";
    autoLogin = lib.mkEnableOption "logging ${vars.username} straight into Hyprland once per boot, after the LUKS passphrase"; #Auto Login after LUKS passphrase
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.desktop.hyprland.enable;
        message = "my.desktop.greeter starts a Hyprland session: also set my.desktop.hyprland.enable = true.";
      }
    ];

    # A greetd greeter styled like Noctalia. This module turns on greetd
    # (which creates the `greeter` system user), AccountsService (user
    # avatars) and polkit. greetd's PAM stack includes `login`, so your
    # login password still unlocks the GNOME keyring.
    services.displayManager.noctalia-greeter = {
      enable = true;

      settings = {
        # Login Defaults
        session.default = "Hyprland (uwsm-managed)";
        user.default = vars.username;
        keyboard.layout = vars.keyboardLayout;
      };

      # Same cursor as your session (desktop/theme.nix)
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
      };

      # Lets you run Noctalia's greeter Sync without an admin password prompt
      passwordlessSyncUsers = [ vars.username ];
    };

    services.displayManager.defaultSession = "hyprland-uwsm";

    services.greetd.settings.initial_session = lib.mkIf cfg.autoLogin {
      user = vars.username;
      command = "${lib.getExe config.programs.uwsm.package} start -e -D Hyprland hyprland.desktop";
    };
  };
}
