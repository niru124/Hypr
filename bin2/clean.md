Good question! Running `yay -Scc` and `pacman -Scc` are solid steps to clean your Arch-based system. However, there are **more ways to reclaim disk space** and keep your system clean. Here’s a full checklist:

---

### ✅ 1. **Remove orphaned packages**

These are packages installed as dependencies that are no longer needed.

```bash
sudo pacman -Rns $(pacman -Qtdq)
```

If `pacman -Qtdq` returns nothing, there are no orphans.

---

### ✅ 2. **Clean package cache more aggressively**

`pacman -Scc` deletes _all_ cached packages, but if you only want to keep the latest version:

```bash
paccache -r  # Removes all but the 3 most recent versions of each package
```

To remove all but the latest version:

```bash
sudo paccache -r -k1
```

To remove all cached packages (like `pacman -Scc` but safer):

```bash
sudo paccache -r -k0
```

If `paccache` is not installed:

```bash
sudo pacman -S pacman-contrib
```

---

### ✅ 3. **Remove unused flatpak packages (if using Flatpak)**

```bash
flatpak uninstall --unused
```

---

### ✅ 4. **Remove unused snaps (if using Snap)**

```bash
sudo snap list --all | awk '/disabled/{print $1, $2}' | while read snapname version; do sudo snap remove "$snapname" --revision="$version"; done
```

---

### ✅ 5. **Remove systemd journal logs**

```bash
sudo journalctl --vacuum-time=7d
```

This keeps logs for the past 7 days only. You can also limit by size:

```bash
sudo journalctl --vacuum-size=100M
```

---

### ✅ 6. **Remove core dumps**

```bash
sudo rm -rf /var/lib/systemd/coredump/*
```

---

### ✅ 7. **Check and remove large unnecessary files**

```bash
sudo du -sh /var/cache/*
sudo du -sh ~/.cache/*
```

Then:

```bash
rm -rf ~/.cache/*
```

---

### ✅ 8. **Clear logs and trash**

```bash
rm -rf ~/.local/share/Trash/*
sudo rm -rf /var/log/*.gz /var/log/*.[0-9]
```

---

### ✅ 9. **Check disk usage**

To find space hogs:

```bash
sudo du -sh /* 2>/dev/null | sort -h
```

Or use a TUI tool:

```bash
sudo pacman -S ncdu
sudo ncdu /
```

---

### ✅ 10. **Remove unused AUR build files (yay)**

```bash
yay -Yc
```

This removes _unneeded_ AUR dependencies.

---

Let me know if you're using a DE like GNOME or KDE, and I can recommend cleanup for thumbnail caches, etc.
