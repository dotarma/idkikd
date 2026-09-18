#!/usr/bin/env bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
WALLPAPERS_DIR="$DOTFILES_DIR/wallpapers"

configs=(
  alacritty
  dunst
  fastfetch
  fish
  i3
  picom
  rofi
)

info()    { printf "  \033[34m·\033[0m %s\n" "$1"; }
success() { printf "  \033[32m✓\033[0m %s\n" "$1"; }
warn()    { printf "  \033[33m!\033[0m %s\n" "$1"; }

echo
printf "\033[1m  dotfiles\033[0m\n"
echo "  ────────────────────"

mkdir -p "$CONFIG_DIR"

for name in "${configs[@]}"; do
  src="$DOTFILES_DIR/.config/$name"
  dst="$CONFIG_DIR/$name"

  if [ ! -d "$src" ]; then
    warn "$name  (source not found, skipping)"
    continue
  fi

  if [ -d "$dst" ] && [ ! -L "$dst" ]; then
    backup="$dst.bak"
    mv "$dst" "$backup"
    warn "$name  (backed up → $name.bak)"
  fi

  if [ -L "$dst" ]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  success "$name"
done

echo "  ────────────────────"

# ── wallpaper ──────────────────────────────────────────────────────────────────
if [ -d "$WALLPAPERS_DIR" ]; then
  mapfile -t walls < <(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)

  if [ ${#walls[@]} -eq 0 ]; then
    warn "wallpapers/  (no images found)"
  else
    echo
    printf "  \033[34mwallpapers\033[0m\n"
    for i in "${!walls[@]}"; do
      printf "  \033[34m%2d\033[0m  %s\n" "$((i+1))" "$(basename "${walls[$i]}")"
    done
    echo
    printf "  pick wallpaper [1-%d]: " "${#walls[@]}"
    read -r choice

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#walls[@]}" ]; then
      selected="${walls[$((choice-1))]}"
      cp "$selected" "$HOME/feh.png"
      success "wallpaper  → ~/feh.png  ($(basename "$selected"))"
    else
      warn "wallpaper  (invalid choice, skipping)"
    fi
  fi
else
  warn "wallpapers/  (folder not found, skipping)"
fi

echo "  ────────────────────"
printf "  \033[1mdone\033[0m\n\n"
