return {
  floating_term = function()
    -- This command will open an external terminal.
    -- The title is set to "FloatingTerminal" to match your Hyprland rules.
    -- You need to configure your window manager (e.g., Hyprland)
    -- to make windows with the class "YaziFloatingTerm" float.
    -- Replace "alacritty" with your preferred terminal emulator and its title/class arguments.
    local terminal_command = os.getenv("YAZI_FLOATING_TERM_CMD") or "kitty --title FloatingTerminal --class YaziFloatingTerm"
    ya.manager.open({ command = { cmd = terminal_command, args = {} }, block = false, orphan = true })
  end,
}
