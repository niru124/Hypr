-- █▄░█ █░█ █ █▀▄ █ ▄▀█
-- █░▀█ ▀▄▀ █ █▄▀ █ █▀█

-- Nvidia environment variables
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- Cursor config
hl.config({
  cursor = {
    no_hardware_cursors = true,
  },
})
