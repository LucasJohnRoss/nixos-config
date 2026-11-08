# Docker
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.virtualisation.docker.enable = lib.mkEnableOption "Docker";

  config = lib.mkIf config.my.virtualisation.docker.enable {
    virtualisation.docker = {
      enable = true;
      # Start on first use (socket activation) instead of at boot — faster boot.
      # On a server whose containers must start at boot, set virtualisation.docker.enableOnBoot = true in that host's file.
      enableOnBoot = lib.mkDefault false;
      autoPrune.enable = true; # weekly `docker system prune`
    };

    # docker without sudo (NB: root-equivalent)
    users.users.${vars.username}.extraGroups = lib.mkIf config.my.system.user.enable [ "docker" ];
  };
}
