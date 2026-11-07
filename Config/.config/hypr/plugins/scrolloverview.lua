-- Scroll-Overview plugin configuration & keybinds
-- Loaded from hyprland.lua at config-parse time. hyprpm loads enabled plugins
-- at startup, so if the plugin is not registered yet we retry for a while.
--
--   SUPER + U        toggle the overview
--   SUPER + HJKL     navigate left / down / up / right (same as arrow keys)
--   arrows           navigate
--   Enter            select, Esc or SUPER + U close

-- `mainMod` is a local in hyprland.lua and is NOT visible inside a dofile()
-- chunk, so it has to be defined again here.
local mainMod = "SUPER"

local function apply()
  hl.config({
    plugin = {
      scrolloverview = {
        gesture_distance = 300,
        scale = 0.5,
        workspace_gap = 100,
        layout = "vertical",
        wallpaper = 0,
        blur = false,

        shadow = {
          enabled = false,
          range = 50,
          render_power = 3,
          color = 0xee1a1a1a,
        },
      },
    },
  })

  -- Toggle the overview on all monitors with SUPER + U. While it is open the
  -- plugin switches to the "scrolloverview" submap defined below.
  hl.bind(mainMod .. " + U", function()
    hl.plugin.scrolloverview.overview("toggle all")
  end)

  hl.define_submap("scrolloverview", function()
    -- HJKL navigate exactly like the arrow keys.
    hl.bind(mainMod .. " + H", hl.plugin.scrolloverview.navigate("left"))
    hl.bind(mainMod .. " + J", hl.plugin.scrolloverview.navigate("down"))
    hl.bind(mainMod .. " + K", hl.plugin.scrolloverview.navigate("up"))
    hl.bind(mainMod .. " + L", hl.plugin.scrolloverview.navigate("right"))

    -- SUPER + U also closes (it is not inherited by the submap automatically).
    hl.bind(mainMod .. " + U", hl.plugin.scrolloverview.overview("toggle all"))
    hl.bind("escape",          hl.plugin.scrolloverview.overview("off"))
    hl.bind("return",          hl.plugin.scrolloverview.overview("select"))
    hl.bind("left",            hl.plugin.scrolloverview.navigate("left"))
    hl.bind("right",           hl.plugin.scrolloverview.navigate("right"))
    hl.bind("up",              hl.plugin.scrolloverview.navigate("up"))
    hl.bind("down",            hl.plugin.scrolloverview.navigate("down"))
  end)
end

local function try_apply()
  if hl.plugin and hl.plugin.scrolloverview then
    apply()
    return true
  end
  return false
end

if not try_apply() then
  -- Plugin not loaded yet: wait for it instead of calling `hyprpm reload`,
  -- which fails with a version mismatch when the plugin was built against
  -- different headers.
  hl.on("hyprland.start", function()
    if try_apply() then
      return
    end

    local tries = 0
    local function wait_for_plugin()
      tries = tries + 1
      if try_apply() then
        return
      end
      if tries < 40 then
        hl.timer(0.5, wait_for_plugin, { type = "oneshot" })
      end
    end

    hl.timer(0.5, wait_for_plugin, { type = "oneshot" })
  end)
end
