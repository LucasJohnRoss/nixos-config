# Locale, time zone, keyboard (from vars)
{
  config,
  lib,
  vars,
  ...
}:
{
  options.my.system.locale.enable = lib.mkEnableOption "your time zone, locale and keyboard layout";

  config = lib.mkIf config.my.system.locale.enable {
    time.timeZone = vars.timezone;
    i18n.defaultLocale = vars.locale;
    services.xserver.xkb.layout = vars.keyboardLayout; # system XKB layout (no X server is installed)
    console.useXkbConfig = true; # TTY + LUKS prompt use the same layout
  };
}
