Cleaning up an Arch Linux system helps keep it fast, lean, and free from unnecessary files. Here's a **comprehensive guide** to safely clean up your Arch system.

---

## 🔧 System Cleanup Steps

### 1. **Clear the Package Cache**

By default, `pacman` keeps a copy of every package you’ve ever downloaded.

```bash
sudo paccache -r
```

- Keeps the **3 most recent versions** (default).
- To keep only **1 version**:

```bash
sudo paccache -rk1
```

- To remove **all** cached versions:

```bash
sudo paccache -r -k0
```

> Requires `pacman-contrib`:

```bash
sudo pacman -S pacman-contrib
```

---

### 2. **Remove Unused Orphaned Packages**

These are packages installed as dependencies but no longer required:

```bash
sudo pacman -Rns $(pacman -Qdtq)
```

- `-Qdtq`: List orphaned dependencies.
- `-Rns`: Remove them along with config files and unused dependencies.

---

### 3. **Clean Up the Journal Logs**

By default, systemd journal logs can grow quite large.

```bash
sudo journalctl --vacuum-time=2weeks
```

- You can change `2weeks` to `7days`, `500M`, etc.

Or limit the size permanently:

```bash
sudo nano /etc/systemd/journald.conf
# Set SystemMaxUse=200M (for example)
```

Then restart journald:

```bash
sudo systemctl restart systemd-journald
```

---

### 4. **Remove Unused Locale Files**

Install `localepurge` (or manually configure `glibc` locales):

> Warning: Be careful with this one.

```bash
sudo pacman -S localepurge
sudo localepurge
```

---

### 5. **Remove Unused Cache & Logs**

You can use tools like `bleachbit` or manually:

```bash
sudo du -sh /var/cache/*
sudo rm -rf /var/cache/pacman/pkg/*
```

Also:

```bash
sudo rm -rf ~/.cache/*
```

---

### 6. **Check for Broken Symlinks**

Clean up dead symlinks:

```bash
find -L / -type l 2>/dev/null
```

Review and delete if necessary.

---

### 7. **Check for Large Files**

Find largest files in your home directory:

```bash
du -ah ~ | sort -rh | head -n 20
```

---

### 8. **Trim SSD (if applicable)**

```bash
sudo fstrim -v /
```

Make it automatic:

```bash
sudo systemctl enable fstrim.timer
```

---

## 🧼 Optional: Use `stow` or `dotcleaner` for dotfiles

If your home directory is cluttered with dotfiles (`.npm`, `.cache`, etc), consider using a manager like [`GNU stow`](https://www.gnu.org/software/stow/) to organize configs.

---

## 💡 Bonus: Use `ncdu` for Disk Space Analysis

```bash
sudo pacman -S ncdu
sudo ncdu /
```

Very helpful visual overview of disk usage.

---

Would you like me to generate a **script** that does most of this automatically?
