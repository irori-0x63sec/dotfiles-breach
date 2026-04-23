# Breach Protocol dotfiles

Cyberpunk 2077 Breach Protocol themed config. Portable between Linux (GNOME) and macOS.

Palette: see [PALETTE.md](PALETTE.md).

## What's inside

```
alacritty/alacritty.toml   terminal colors + window + font
tmux/tmux.conf             status bar
zsh/zshrc                  Powerlevel10k + plugins + syntax-hl colors
gtk-3.0/gtk.css            GTK3 headerbar / window controls (Linux)
gtk-4.0/gtk.css            GTK4 / libadwaita overrides (Linux)
gnome-shell/BreachProtocol GNOME Shell theme (Linux)
misc/ghostty.config        drop-in for Ghostty terminal
misc/BreachProtocol.itermcolors  iTerm2 color preset (macOS)
install.sh                 symlink installer
```

## Install

### Linux (GNOME 48, Debian/Ubuntu)

```bash
./install.sh linux
# then:
chsh -s $(which zsh)
gsettings set org.gnome.shell.extensions.user-theme name 'BreachProtocol'
# Alt+F2 → r → Enter to reload shell
```

Extras (not automated — install only if you need them):
- Recolored icon theme: clone Papirus and run the recolor perl script (see `misc/`)
- Mozc candidate popup: `sudo mv /usr/lib/mozc/mozc_renderer /usr/lib/mozc/mozc_renderer.disabled && ibus restart`
- GDM login screen: use `gdm-settings` (flatpak)

### macOS

```bash
./install.sh macos
```

Installs: alacritty, tmux, zsh plugins, Powerlevel10k, JetBrainsMono Nerd Font via brew.
Symlinks tmux/zsh/alacritty.

**macOS has no equivalent for**:
- GTK / GNOME Shell theming (system Chrome is locked by SIP)
- Linux icon themes (use `LiteIcon` to manually swap per-app `.icns`)
- Mozc candidate popup (macOS IME can't be themed)

System Settings → Appearance: Dark + Accent=Yellow gets closest to the Breach vibe.

For iTerm2 users: `open misc/BreachProtocol.itermcolors` to import.
For Ghostty users: `cp misc/ghostty.config ~/.config/ghostty/config`.

### Minimal (any OS, no deps)

```bash
./install.sh minimal
```

Just symlinks the 3 terminal-stack files. Assumes deps already present.

## Uninstall

Symlinks are in:
- `~/.tmux.conf`
- `~/.zshrc`
- `~/.config/alacritty/alacritty.toml`
- `~/.config/gtk-3.0/gtk.css` (Linux)
- `~/.config/gtk-4.0/gtk.css` (Linux)
- `~/.themes/BreachProtocol/` (Linux)

Originals (if they existed) were backed up with `.before-breach.<timestamp>` suffix.
