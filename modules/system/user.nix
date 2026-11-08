# Your user account (the name comes from vars.username).
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.system.user.enable = lib.mkEnableOption "the ${vars.username} user account";

  config = lib.mkIf config.my.system.user.enable {
    users.users.${vars.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # sudo
    };
  };
}
