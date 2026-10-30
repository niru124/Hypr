#!/usr/bin/env bash
set -euo pipefail

# rofi-pass.sh — Rofi frontend for pass with wl-copy and QR code support
# Requires: pass, rofi, wl-copy, qrencode, yad (preferred), zenity (fallback), xdg-open

PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
TMPDIR="${TMPDIR:-/tmp}"
ROFI_THEME="~/.config/rofi/pass.rasi"
CLEANUP_FILES=()

cleanup() {
    for f in "${CLEANUP_FILES[@]:-}"; do
        [[ -f "$f" ]] && shred -u -z "$f" 2>/dev/null || rm -f "$f" 2>/dev/null
    done
}
trap cleanup EXIT

# Helper: pick an existing entry
pick_entry() {
    (cd "$PASSWORD_STORE_DIR" && find . -type f -name "*.gpg" | sed 's|^\./||; s|\.gpg$||') | rofi -dmenu -p "$1" -i -theme "$ROFI_THEME"
}

# Helper: display text in a dialog (zenity fallback)
show_text_dialog() {
    local title="$1"; shift
    local text="$*"
    if command -v yad >/dev/null 2>&1; then
        yad --text-info --title="$title" --button=OK --geometry=500x300 <<<"$text"
    else
        zenity --info --title="$title" --width=500 --text="$(printf '%s' "$text")"
    fi
}

# Helper: display image (QR)
show_image() {
    local img="$1"
    if command -v yad >/dev/null 2>&1; then
        yad --image="$img" --title="QR Code" --button=OK --width=300 --height=350
    else
        # fallback: try xdg-open, feh, or display (ImageMagick)
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$img"
        elif command -v feh >/dev/null 2>&1; then
            feh --auto-zoom --title "QR Code" "$img"
        elif command -v display >/dev/null 2>&1; then
            display "$img"
        else
            # As ultimate fallback show ascii qr in rofi/zenity
            if command -v qrencode >/dev/null 2>&1; then
                qrencode -t ANSIUTF8 -o - < <(pass "$entry" | head -n1) | rofi -dmenu -p "QR (text)" -i
            else
                zenity --error --text="No image viewer available to show QR."
            fi
        fi
    fi
}

# Helper: create QR for given text; returns path
make_qr() {
    local text="$1"
    local out
    out="$(mktemp --tmpdir qr.XXXXXX.png)"
    CLEANUP_FILES+=("$out")
    # stronger error handling disabled to allow qrencode errors to surface
    printf '%s' "$text" | qrencode -o "$out" -s 8 -l M
    echo "$out"
}

# Helper: add and commit changes to the password store if it's a git repo
git_commit_changes() {
    local commit_message="$1"
    if [[ -d "$PASSWORD_STORE_DIR/.git" ]]; then
        (cd "$PASSWORD_STORE_DIR" && git add -A && git commit -m "$commit_message" >/dev/null 2>&1 || true)
    fi
}

generate_password() {
    local length password entry

    length=$(rofi -dmenu -p "Password length (default 16):" -theme "$ROFI_THEME")
    [[ -z "$length" ]] && length=16
    # Validate length is numeric
    if ! [[ "$length" =~ ^[0-9]+$ ]]; then
        notify-send "pass" "Invalid length: $length. Using default 16."
        length=16
    fi
    [[ "$length" -lt 1 ]] && length=16

    local include_digits include_special_characters custom_symbols chars

    include_digits=$(printf "Yes\nNo" | rofi -dmenu -p "Include digits?" -theme "$ROFI_THEME")
    include_special_characters=$(printf "Yes\nNo\nAdvanced" | rofi -dmenu -p "Include special characters?" -theme "$ROFI_THEME")

    # Build character set using arrays to avoid tr range interpretation issues
    local char_array=()
    # Always include letters
    for c in {a..z}; do char_array+=("$c"); done
    for c in {A..Z}; do char_array+=("$c"); done

    if [[ "$include_digits" == "Yes" ]]; then
        for c in {0..9}; do char_array+=("$c"); done
    fi

    if [[ "$include_special_characters" == "Yes" ]]; then
        local special='!@#$%^&*()_+={}[]|;:,.<>?'
        for (( i=0; i<${#special}; i++ )); do
            char_array+=("${special:$i:1}")
        done
    elif [[ "$include_special_characters" == "Advanced" ]]; then
        custom_symbols=$(rofi -dmenu -p "Enter custom special characters:" -theme "$ROFI_THEME")
        if [[ -n "$custom_symbols" ]]; then
            for (( i=0; i<${#custom_symbols}; i++ )); do
                char_array+=("${custom_symbols:$i:1}")
            done
        else
            notify-send "pass" "No custom symbols entered. Generating without special characters."
        fi
    fi

    # Generate password character by character
    local num_chars=${#char_array[@]}
    if [[ "$num_chars" -eq 0 ]]; then
        notify-send "pass" "Error: no characters available for password generation."
        return
    fi
    password=""
    for (( i=0; i<length; i++ )); do
        password+="${char_array[$((RANDOM % num_chars))]}"
    done

    entry=$(rofi -dmenu -p "Store as (e.g. mail/account):" -theme "$ROFI_THEME")
    [[ -z "$entry" ]] && return

    if [[ ! -f "$PASSWORD_STORE_DIR/.gpg-id" ]]; then
        notify-send "pass" "Password store not initialized. Run: pass init <your-gpg-id>"
        return
    fi

    if ! echo "$password" | pass insert -m -f "$entry" 2>/tmp/pass_insert_err; then
        notify-send "pass" "Failed to store password: $(cat /tmp/pass_insert_err 2>/dev/null)"
        return
    fi
    printf '%s' "$password" | wl-copy
    notify-send "pass" "Generated password for $entry (copied to clipboard)"
    git_commit_changes "Generate password for $entry"
}

### 2. Passphrase Generator (diceware style) ###

generate_passphrase() {
    local wordcount passphrase entry

    wordcount=$(rofi -dmenu -p "Number of words in passphrase (default 5):" -theme "$ROFI_THEME")
    [[ -z "$wordcount" ]] && wordcount=5

    if [[ ! -f /usr/share/dict/words ]]; then
        notify-send "pass" "Dictionary file /usr/share/dict/words not found!"
        return
    fi

    passphrase=$(shuf -n "$wordcount" /usr/share/dict/words | tr '\n' ' ' | sed 's/ $//')

    entry=$(rofi -dmenu -p "Store as (e.g. mail/account):" -theme "$ROFI_THEME")
    [[ -z "$entry" ]] && return

    echo "$passphrase" | pass insert -m "$entry"
    printf '%s' "$passphrase" | wl-copy
    notify-send "pass" "Generated passphrase for $entry (copied to clipboard)"
    git_commit_changes "Generate passphrase for $entry"
}

show_password_history() {
    local entry history

    entry=$(pick_entry "Show history for:")
    [[ -z "$entry" ]] && return

    cd "$PASSWORD_STORE_DIR"

    if [[ ! -f "${entry}.gpg" ]]; then
        notify-send "pass" "Entry not found: $entry"
        return
    fi

    history=$(git log --pretty=format:"%h - %an, %ar%n%s" -- "${entry}.gpg" | head -n 20)
    if [[ -z "$history" ]]; then
        notify-send "pass" "No git history found for $entry"
        return
    fi

    echo "$history" | rofi -dmenu -p "History for $entry" -lines 10 -theme "$ROFI_THEME"
}

### 4. Restore Old Password Version ###

restore_old_password() {
    local entry history selected old_content confirm file_path

    entry=$(pick_entry "Restore old version for:")
    [[ -z "$entry" ]] && return

    cd "$PASSWORD_STORE_DIR"
    file_path="${entry}.gpg"

    if [[ ! -f "$file_path" ]]; then
        notify-send "pass" "Entry not found: $entry"
        return
    fi

    history=$(git log --pretty=format:"%h %ad" --date=short -- "$file_path" | head -n 20)
    selected=$(echo "$history" | rofi -dmenu -p "Select commit hash to restore:" -theme "$ROFI_THEME" | awk '{print $1}')
    [[ -z "$selected" ]] && return

    old_content=$(git show "${selected}:${file_path}" | gpg --decrypt 2>/dev/null)
    if [[ -z "$old_content" ]]; then
        notify-send "pass" "Failed to decrypt old version"
        return
    fi

    confirm=$(printf "No\nYes" | rofi -dmenu -p "Restore selected version?" -theme "$ROFI_THEME")
    if [[ "$confirm" == "Yes" ]]; then
        echo "$old_content" | pass insert -m -f "$entry"
        notify-send "pass" "Restored old version for $entry"
        git_commit_changes "Restore old version of $entry"
    fi
}

# Helper: pick a file via GUI dialog
pick_file() {
    local title="${1:-Select a file}"
    if command -v yad >/dev/null 2>&1; then
        yad --file --title="$title" --filename="$HOME/" 2>/dev/null
    elif command -v zenity >/dev/null 2>&1; then
        zenity --file-selection --title="$title" --filename="$HOME/"
    else
        rofi -dmenu -p "File path:" -theme "$ROFI_THEME"
    fi
}

# Helper: get default GPG recipient from pass config
get_gpg_recipient() {
    local id_file="${PASSWORD_STORE_DIR}/.gpg-id"
    if [[ -f "$id_file" ]]; then
        head -n1 "$id_file"
    else
        gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep '^sec' | head -n1 | awk '{print $2}' | cut -d'/' -f2
    fi
}

file_operations() {
    local action

    action=$(printf "%s\n" \
        "🔒 Encrypt file" \
        "🔓 Decrypt file" \
        "✍️ Sign file" \
        "✅ Verify signature" \
        | rofi -dmenu -p "File operation:" -i -theme "$ROFI_THEME")

    [[ -z "$action" ]] && return

    case "$action" in
        "🔒 Encrypt file")
            local infile outfile recipient
            infile=$(pick_file "Select file to encrypt")
            [[ -z "$infile" ]] && return
            outfile="${infile}.gpg"
            if [[ -f "$outfile" ]]; then
                local overwrite
                overwrite=$(printf "No\nYes" | rofi -dmenu -p "$outfile exists. Overwrite?" -theme "$ROFI_THEME")
                [[ "$overwrite" != "Yes" ]] && return
            fi
            recipient=$(get_gpg_recipient)
            if [[ -z "$recipient" ]]; then
                notify-send "pass" "No GPG key found!"
                return
            fi
            gpg -e -r "$recipient" -o "$outfile" "$infile" && \
                notify-send "pass" "Encrypted: $(basename "$infile") → $(basename "$outfile")" || \
                notify-send "pass" "Encryption failed!"
            ;;
        "🔓 Decrypt file")
            local infile outfile
            infile=$(pick_file "Select .gpg file to decrypt")
            [[ -z "$infile" ]] && return
            outfile="${infile%.gpg}"
            if [[ -f "$outfile" ]]; then
                local overwrite
                overwrite=$(printf "No\nYes" | rofi -dmenu -p "$outfile exists. Overwrite?" -theme "$ROFI_THEME")
                [[ "$overwrite" != "Yes" ]] && return
            fi
            gpg -d -o "$outfile" "$infile" && \
                notify-send "pass" "Decrypted: $(basename "$infile") → $(basename "$outfile")" || \
                notify-send "pass" "Decryption failed!"
            ;;
        "✍️ Sign file")
            local infile outfile
            infile=$(pick_file "Select file to sign")
            [[ -z "$infile" ]] && return
            outfile="${infile}.sig"
            if [[ -f "$outfile" ]]; then
                local overwrite
                overwrite=$(printf "No\nYes" | rofi -dmenu -p "$outfile exists. Overwrite?" -theme "$ROFI_THEME")
                [[ "$overwrite" != "Yes" ]] && return
            fi
            gpg --detach-sign -o "$outfile" "$infile" && \
                notify-send "pass" "Signed: $(basename "$infile") → $(basename "$outfile")" || \
                notify-send "pass" "Signing failed!"
            ;;
        "✅ Verify signature")
            local sigfile infile result
            sigfile=$(pick_file "Select .sig file")
            [[ -z "$sigfile" ]] && return
            infile=$(pick_file "Select original file")
            [[ -z "$infile" ]] && return
            result=$(gpg --verify "$sigfile" "$infile" 2>&1)
            if command -v yad >/dev/null 2>&1; then
                yad --text-info --title="Verify result" --button=OK --geometry=400x200 <<<"$result"
            else
                notify-send "pass" "Verify result" "$result"
            fi
            ;;
    esac
}

backup_restore_menu() {
    local action

    action=$(printf "%s\n" \
        "💾 Backup GPG keys" \
        "📂 Restore GPG keys" \
        | rofi -dmenu -p "Backup & Restore:" -i -theme "$ROFI_THEME")

    [[ -z "$action" ]] && return

    case "$action" in
        "💾 Backup GPG keys")
            local outdir recipient
            recipient=$(get_gpg_recipient)
            if [[ -z "$recipient" ]]; then
                notify-send "pass" "No GPG key found!"
                return
            fi

            outdir=$(pick_file "Select backup directory")
            [[ -z "$outdir" ]] && return
            if [[ ! -d "$outdir" ]]; then
                mkdir -p "$outdir"
            fi

            gpg --export-secret-keys --armor "$recipient" > "$outdir/gpg-private.asc" && \
            gpg --export --armor "$recipient" > "$outdir/gpg-public.asc" && \
            gpg --export-ownertrust > "$outdir/gpg-ownertrust.txt" && \
            notify-send "pass" "GPG keys backed up to $outdir" || \
            notify-send "pass" "Backup failed!"
            ;;
        "📂 Restore GPG keys")
            local dir
            dir=$(pick_file "Select backup directory containing gpg-*.asc files")
            [[ -z "$dir" ]] && return
            if [[ -f "$dir/gpg-public.asc" && -f "$dir/gpg-private.asc" ]]; then
                gpg --import "$dir/gpg-public.asc" "$dir/gpg-private.asc" && \
                [[ -f "$dir/gpg-ownertrust.txt" ]] && gpg --import-ownertrust < "$dir/gpg-ownertrust.txt" && \
                notify-send "pass" "GPG keys restored from $dir" || \
                notify-send "pass" "Restore failed!"
            else
                notify-send "pass" "Missing gpg-public.asc or gpg-private.asc in $dir"
            fi
            ;;
    esac
}

# Main menu
action=$(printf "%s\n" \
  "📋 Copy to clipboard" \
  "👁 Show password" \
  "➕ Insert new password (GUI)" \
  "🧾 List all entries" \
  "🔍 Search entries" \
  "✏️ Edit entry" \
  "🗑 Delete entry" \
  "🔐 Generate new password (advanced)" \
  "🔑 Generate passphrase" \
  "📜 Show password history" \
  "↩️ Restore old password version" \
  "🔳 Show QR for entry" \
  "🧰 Use in script (copy snippet)" \
  "📝 Insert multiline secret" \
  "📁 File operations (encrypt/sign)" \
  "🔄 Backup & Restore" \
  "🫸🏽 Push updated passwords to github" \
  "🫸🏽 Synchronize from github" \
  | rofi -dmenu -p "Pass action:" -i -theme "$ROFI_THEME")

[[ -z "$action" ]] && exit 0

case "$action" in

  "📋 Copy to clipboard")
    entry=$(pick_entry "Copy password for:")
    [[ -z "$entry" ]] && exit 0
    password="$(pass "$entry" | head -n1)"
    printf '%s' "$password" | wl-copy
    notify-send "pass" "Password copied to clipboard"
    ;;

  "👁 Show password")
    entry=$(pick_entry "Show password for:")
    [[ -z "$entry" ]] && exit 0
    show_text_dialog "Password for $entry" "$(pass "$entry")"
    ;;

  "➕ Insert new password (GUI)")
    entry=$(rofi -dmenu -p "New entry (e.g. mail/account):" -theme "$ROFI_THEME")
    [[ -z "$entry" ]] && exit 0
    # prompt for password via rofi hidden input
    password=$(rofi -dmenu -password -p "Password (hidden):" -theme "$ROFI_THEME")
    [[ -z "$password" ]] && exit 0
    echo "$password" | pass insert -m "$entry"
    notify-send "pass" "Inserted $entry"
    git_commit_changes "Add $entry"
    ;;

  "🧾 List all entries")
    (cd "$PASSWORD_STORE_DIR" && find . -type f -name "*.gpg" | sed 's|^\./||; s|\.gpg$||' | sort) | rofi -dmenu -p "Entries - press Esc to close" -no-custom -i -theme "$ROFI_THEME"
    ;;

  "🔍 Search entries")
    query=$(rofi -dmenu -p "Search for:" -theme "$ROFI_THEME")
    [[ -z "$query" ]] && exit 0
    pass find "$query" | rofi -dmenu -p "Search results for '$query':" -i -theme "$ROFI_THEME"
    ;;

  "✏️ Edit entry")
    entry=$(pick_entry "Edit entry:")
    [[ -z "$entry" ]] && exit 0

    edit_action=$(printf "Change Password\nRename Entry" | rofi -dmenu -p "Edit action for $entry:" -theme "$ROFI_THEME")
    [[ -z "$edit_action" ]] && exit 0

    case "$edit_action" in
      "Change Password")
        new_password=$(rofi -dmenu -password -p "New password (hidden) for $entry:" -theme "$ROFI_THEME")
        [[ -z "$new_password" ]] && exit 0
        echo "$new_password" | pass insert -f -m "$entry"
        notify-send "pass" "Updated password for $entry"
        git_commit_changes "Update password for $entry"
        ;;
      "Rename Entry")
        new_entry_name=$(rofi -dmenu -p "New name for $entry:" -theme "$ROFI_THEME")
        [[ -z "$new_entry_name" ]] && exit 0
        pass mv "$entry" "$new_entry_name"
        notify-send "pass" "Renamed $entry to $new_entry_name"
        git_commit_changes "Rename $entry to $new_entry_name"
        ;;
    esac
    ;;

  "🗑 Delete entry")
    entry=$(pick_entry "Delete entry:")
    [[ -z "$entry" ]] && exit 0
    confirm=$(printf "No\nYes" | rofi -dmenu -p "Really delete $entry?" -theme "$ROFI_THEME")
    [[ "$confirm" == "Yes" ]] && pass rm -f "$entry" && notify-send "pass" "Deleted $entry" && git_commit_changes "Delete $entry"
    ;;

  "🔐 Generate new password (advanced)")
    generate_password
    ;;

  "🔑 Generate passphrase")
    generate_passphrase
    ;;

  "📜 Show password history")
    show_password_history
    ;;

  "↩️ Restore old password version")
    restore_old_password
    ;;

  "🔳 Show QR for entry")
    entry=$(pick_entry "Show QR for:")
    [[ -z "$entry" ]] && exit 0
    password="$(pass "$entry" | head -n1)"
    qrfile="$(make_qr "$password")"
    # copy password to clipboard as well
    printf '%s' "$password" | wl-copy
    show_image "$qrfile"
    notify-send "pass" "Password copied to clipboard and QR displayed"
    ;;

  "🧰 Use in script (copy snippet)")
    entry=$(pick_entry "Get snippet for:")
    [[ -z "$entry" ]] && exit 0
    snippet="MAIL_PASS=\"\$(pass $entry | head -n1)\""
    printf '%s' "$snippet" | wl-copy
    notify-send "pass" "Script snippet copied to clipboard"
    ;;

  "📝 Insert multiline secret")
    entry=$(rofi -dmenu -p "Entry name (e.g. notes/mysecret):" -theme "$ROFI_THEME")
    [[ -z "$entry" ]] && exit 0
    longsecret=$(rofi -dmenu -p "Paste or type your multiline secret:" -theme "$ROFI_THEME")
    [[ -z "$longsecret" ]] && exit 0
    echo "$longsecret" | pass insert --multiline "$entry"
    notify-send "pass" "Inserted multiline secret for $entry"
    git_commit_changes "Add multiline secret $entry"
    ;;

  "📁 File operations (encrypt/sign)")
    file_operations
    ;;

  "🔄 Backup & Restore")
    backup_restore_menu
    ;;

  "🫸🏽 Push updated passwords to github")
cd "${PASSWORD_STORE_DIR}" && git push origin HEAD && notify-send "pass-sync" "Password added to github"
;;

  "🫸🏽 Synchronize from github")
cd "${PASSWORD_STORE_DIR}" && git pull --rebase origin HEAD && notify-send "pass-sync" "Password store updated from GitHub"
;;
  *)

    exit 0
    ;;
esac

