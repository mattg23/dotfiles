#!/usr/bin/env bash
set -euo pipefail

is_installed() {
  local pkg="$1"

  # dpkg / apt
  if command -v dpkg >/dev/null 2>&1 &&
     dpkg -s "$pkg" >/dev/null 2>&1; then
    return 0
  fi

  # snap
  if command -v snap >/dev/null 2>&1 &&
     snap list 2>/dev/null | awk '{print $1}' | grep -qx "$pkg"; then
    return 0
  fi

  # flatpak (flathub apps)
  if command -v flatpak >/dev/null 2>&1 &&
     flatpak list --app 2>/dev/null | awk '{print $1}' | grep -qx "$pkg"; then
    return 0
  fi

  return 1
}

install_apt() {
  local pkg="$1"

  if is_installed "$pkg"; then
    echo "[apt] $pkg already installed"
    return 0
  fi

  sudo apt install -y "$pkg"
}

install_snap() {
  local pkg="$1"

  if is_installed "$pkg"; then
    echo "[snap] $pkg already installed"
    return 0
  fi

  snap install "$pkg"
}

install_flathub() {
  local pkg="$1"

  if is_installed "$pkg"; then
    echo "[flatpak] $pkg already installed"
    return 0
  fi

  # ensure flathub remote exists
  if ! flatpak remote-list | awk '{print $1}' | grep -qx flathub; then
    flatpak remote-add --if-not-exists flathub \
      https://flathub.org/repo/flathub.flatpakrepo
  fi

  flatpak install -y flathub "$pkg"
}

