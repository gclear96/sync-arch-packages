#!/bin/bash

# Path to your cloned git repository
REPO_PATH="$HOME/arch-pkgs"
NATIVE_LIST="${REPO_PATH}/native.txt"
AUR_LIST="${REPO_PATH}/aur.txt"

# Exit if the repo path doesn't exist
if [ ! -d "$REPO_PATH" ]; then
  echo "Package list repository not found at $REPO_PATH"
  exit 1
fi

cd "$REPO_PATH"

# Prevent script from running if another instance is already running
exec 200>"${REPO_PATH}/.lock"
flock -n 200 || exit 1

# Pull the latest changes from the repository
git pull

# --- INSTALL MISSING PACKAGES ---

# Install missing native packages
comm -23 <(sort "$NATIVE_LIST") <(pacman -Qeq | sort) | sudo pacman -S --needed -

# Install missing AUR packages (using yay, change if you use another helper)
if command -v yay &>/dev/null; then
  comm -23 <(sort "$AUR_LIST") <(pacman -Qmq | sort) | yay -S --needed -
fi

# --- REMOVE EXTRANEOUS PACKAGES (PRUNING) ---

# WARNING: This section will automatically uninstall packages.
# It finds packages that are installed locally but are NOT in the master list.

# Prune native packages
comm -13 <(sort "$NATIVE_LIST") <(pacman -Qeq | sort) | sudo pacman -Rns -

# Prune AUR packages
if command -v yay &>/dev/null; then
  comm -13 <(sort "$AUR_LIST") <(pacman -Qmq | sort) | yay -Rns -
fi
