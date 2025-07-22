# Personal Zsh configuration file. It is strongly recommended to keep all
# shell customization and configuration (including exported environment
# variables such as PATH) in this file or in files sourced from it.
#
# Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'yes'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Clone additional Git repositories from GitHub.
#
# This doesn't do anything apart from cloning the repository and keeping it
# up-to-date. Cloned files can be used after `z4h init`. This is just an
# example. If you don't plan to use Oh My Zsh, delete this line.
z4h install ohmyzsh/ohmyzsh || return

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/bin $path)

# Export environment variables.
export GPG_TTY=$TTY

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Use additional Git repositories pulled in with `z4h install`.
#
# This is just an example that you should delete. It does nothing useful.
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

# Define named directories: ~w <=> Windows home directory on WSL.
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# Define aliases.
alias tree='tree -a -I .git'
eval "$(zoxide init zsh)"
export EDITOR=nvim


# invert color of pdf
invertpdf() {
  if [ -z "$1" ]; then
    echo "Usage: invertpdf input.pdf [output.pdf]"
    return 1
  fi

  input="$1"
  output="${2:-inverted_$1}"

  pdftoppm "$input" temp -png
  convert temp*.png -negate "$output"
  rm temp*.png
  echo "Saved inverted PDF as $output"
}

# Function to preview image using kitty's icat
icat() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: icat <image-file>"
    return 1
  fi

  # Pass all arguments as a list (handles spaces)
  kitty +kitten icat "$@"
}

# delete and copy
clean() {
    src="$1"
    dest="$2"

    if [[ -z "$src" || -z "$dest" ]]; then
        echo "Usage: copy_clean <source> <destination>"
        return 1
    fi

    base_name=$(basename "$src")
    target_path="${dest%/}/$base_name"

    if [[ -e "$target_path" ]]; then
        echo "Removing existing: $target_path"
        rm -rf "$target_path"
    fi

    echo "Copying $src to $dest"
    rsync -a --progress "$src" "$dest"
}

# fzf with preview
alias fz='fzf --preview "bat --style=numbers --color=always --line-range :500 {}"'

#manpage using neovim
export MANPAGER='nvim +Man!'

# better scoll
alias inject='input-remapper-control --command start --device "Raspberry Pi Pico Mouse" --preset "faster.json"'

# Add flags to existing aliases.
alias ls="${aliases[ls]:-ls} -A"

# tmux and fzf
tmux-fzf-session() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | fzf --prompt="Select tmux session: ")

  if [[ -n $session ]]; then
    # Ask whether to attach or kill
    action=$(printf "attach\nkill" | fzf --prompt="Action for [$session]: ")

    if [[ $action == "attach" ]]; then
      tmux attach -t "$session"
    elif [[ $action == "kill" ]]; then
      tmux kill-session -t "$session"
      echo "Killed session: $session"
    fi
  fi
}

# better notify
msg() {
    ICON_DIR="$HOME/.config/dunst/icons/random"
    ICON=$(find "$ICON_DIR" -type f -name "*.svg" | shuf -n 1)

    # Fallback if no icon is found
    [ -z "$ICON" ] && ICON="dialog-information"

    notify-send -i "$ICON" "$@"
}

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt no_auto_menu  # require an extra TAB press to open the completion menu
