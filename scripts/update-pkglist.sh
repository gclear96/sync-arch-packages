#!/bin/bash

# Path to your cloned git repository
REPO_PATH="$HOME/arch-pkgs"

# Exit if the repo path doesn't exist
if [ ! -d "$REPO_PATH" ]; then
  echo "Package list repository not found at $REPO_PATH"
  exit 1
fi

cd "$REPO_PATH"

# Prevent script from running if another instance is already running
exec 200>"${REPO_PATH}/.lock"
flock -n 200 || exit 1

# Generate package lists
# Native packages (from official repos)
pacman -Qeq >native.txt
# AUR packages (change `yay` to your AUR helper if needed)
pacman -Qmq >aur.txt

# Check if there are any changes to commit
if ! git diff --quiet; then
  git add native.txt aur.txt
  git commit -m "Auto-update package list ($(hostname))"
  git push
fi
