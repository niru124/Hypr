-- Scroll-Overview plugin configuration & keybinds
-- Loaded after the plugin registers its keywords/dispatchers
-- (fired from the hyprland.start handler in hyprland.lua after `hyprpm reload`).

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

  hl.bind("SUPER + H", function()
    hl.plugin.scrolloverview.overview("toggle all")
  end)

  hl.define_submap("scrolloverview", function()
    hl.bind(mainMod .. " + J", hl.plugin.scrolloverview.navigate("down"))
    hl.bind(mainMod .. " + K", hl.plugin.scrolloverview.navigate("up"))
    hl.bind("SUPER + H",    hl.plugin.scrolloverview.overview("off"))
    hl.bind("escape",       hl.plugin.scrolloverview.overview("off"))
    hl.bind("return",       hl.plugin.scrolloverview.overview("select"))
    hl.bind("left",         hl.plugin.scrolloverview.navigate("left"))
    hl.bind("right",        hl.plugin.scrolloverview.navigate("right"))
    hl.bind("up",           hl.plugin.scrolloverview.navigate("up"))
    hl.bind("down",         hl.plugin.scrolloverview.navigate("down"))
  end)
end

if hl.plugin and hl.plugin.scrolloverview then
  apply()
else
  hl.on("hyprland.start", function()
    local tries = 0
    local function wait_for_plugin()
      tries = tries + 1
      if hl.plugin and hl.plugin.scrolloverview then
        apply()
      elseif tries < 20 then
        hl.timer(0.5, wait_for_plugin, { type = "oneshot" })
      end
    end
    hl.exec_cmd("hyprpm reload -n")
    hl.timer(0.5, wait_for_plugin, { type = "oneshot" })
  end)
end
