mp.register_event("file-loaded", function()
  local count = mp.get_property_number("playlist-count")
  if count > 1 then
    mp.command("playlist-clear")
  end
end)