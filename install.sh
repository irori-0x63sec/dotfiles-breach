#!/usr/bin/env bash
# Breach Protocol dotfiles installer
# Usage: ./install.sh [linux|macos|minimal]
#   linux   — full stack (Alacritty + tmux + zsh + GTK + GNOME Shell)
#   macos   — terminal-only (Alacritty + tmux + zsh)
#   minimal — just symlink dotfiles, no deps install

set -e

DOT="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-minimal}"
OS="$(uname -s)"

echo "[Breach Protocol] mode=$MODE os=$OS dotfiles=$DOT"

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    [ -e "$dst" ] && mv "$dst" "$dst.before-breach.$(date +%s)"
    ln -s "$src" "$dst"
    echo "  linked $dst -> $src"
}

install_deps_linux() {
    echo "[deps] Debian/Ubuntu stack"
    sudo apt update
    sudo apt install -y alacritty tmux zsh git curl \
        fonts-jetbrains-mono gpick papirus-icon-theme \
        gnome-shell-extension-user-theme \
        gnome-shell-extension-desktop-icons-ng
    # zsh plugins
    mkdir -p ~/.zsh/plugins
    [ -d ~/.zsh/plugins/zsh-autosuggestions ] || \
        git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
    [ -d ~/.zsh/plugins/zsh-syntax-highlighting ] || \
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
    [ -d ~/powerlevel10k ] || \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
}

install_deps_macos() {
    echo "[deps] brew stack"
    command -v brew >/dev/null 2>&1 || {
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    }
    brew install alacritty tmux zsh powerlevel10k zsh-autosuggestions zsh-syntax-highlighting \
        font-jetbrains-mono-nerd-font
}

link_terminal_stack() {
    link "$DOT/tmux/tmux.conf"         "$HOME/.tmux.conf"
    link "$DOT/zsh/zshrc"              "$HOME/.zshrc"
    link "$DOT/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
}

link_linux_gui() {
    link "$DOT/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
    link "$DOT/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    mkdir -p "$HOME/.themes"
    [ -e "$HOME/.themes/BreachProtocol" ] || \
        ln -s "$DOT/gnome-shell/BreachProtocol" "$HOME/.themes/BreachProtocol"
    echo "  GNOME Shell theme at ~/.themes/BreachProtocol"
}

case "$MODE" in
    linux)
        [ "$OS" = "Linux" ] || { echo "--linux on non-Linux"; exit 1; }
        install_deps_linux
        link_terminal_stack
        link_linux_gui
        echo "[done] Next:"
        echo "  1. chsh -s \$(which zsh)"
        echo "  2. GNOME Shell: Alt+F2 → r → Enter"
        echo "  3. gsettings set org.gnome.shell.extensions.user-theme name 'BreachProtocol'"
        ;;
    macos)
        [ "$OS" = "Darwin" ] || { echo "--macos on non-Darwin"; exit 1; }
        install_deps_macos
        link_terminal_stack
        # macOS zshrc expects different paths for plugins/p10k — rewrite
        sed -i '' \
          -e 's|~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh|/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh|' \
          -e 's|~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|' \
          -e 's|~/powerlevel10k/powerlevel10k.zsh-theme|/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme|' \
          "$HOME/.zshrc" 2>/dev/null || true
        echo "[done] restart your terminal. iTerm2 users: import misc/BreachProtocol.itermcolors"
        ;;
    minimal)
        link_terminal_stack
        echo "[done] symlinks only. Install deps manually."
        ;;
    *)
        echo "usage: $0 [linux|macos|minimal]"
        exit 1
        ;;
esac
