-- Monitors for the gaming PC (GamingDesktop). Loaded by hyprland.lua by hostname.
-- See https://wiki.hypr.land/configuring/core/monitors/
--
-- TODO after install: run `hyprctl monitors all` and replace the output names,
-- modes and positions below. Positions are in logical pixels (after scaling):
-- a second screen to the right of a 2560-wide one starts at "2560x0".
-- Saving this file reloads Hyprland, so you can tune it live.

-- Main monitor (left)
hl.monitor({
    output   = "DP-1",             -- TODO: real connector name
    mode     = "1920x1080@144",    -- TODO: resolution@refresh
    position = "0x0",
    scale    = "1",
})

-- Second monitor (right)
hl.monitor({
    output   = "HDMI-A-1",         -- TODO: real connector name
    mode     = "1920x1080@60",     -- TODO: resolution@refresh
    position = "1920x0",           -- = main monitor's width
    scale    = "1",
})

-- Fallback for any other connector: preferred mode, placed automatically.
-- Until the TODOs above are filled in, this alone gives you a working layout.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
