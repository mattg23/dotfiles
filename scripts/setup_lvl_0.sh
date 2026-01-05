#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

source "$(dirname "$0")/lib.sh"

# Colors for pretty printing
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Level 0: Core System Setup ===${NC}"

echo -e "${GREEN}--> Updating APT repositories...${NC}"
sudo apt update

echo -e "${GREEN}--> installing Zsh and core CLI tools...${NC}"
sudo apt install -y zsh git curl wget build-essential unzip htop fastfetch tree fzf ripgrep fd-find

echo -e "${GREEN}--> installing EurKEY...${NC}"
if ! is_installed "eurkey"; then
    tmpdeb=$(mktemp /tmp/eurkey.XXXXX.deb)
    trap 'rm -f "$tmpdeb"' EXIT
    curl -fsSL "https://eurkey.steffen.bruentjen.eu/download/debian/binary/eurkey.deb" -o "$tmpdeb" 
    sudo apt install -y "$tmpdeb"
else
    echo "EurKEY already installed."
fi

echo -e "${GREEN}--> Installing Thunderbird...${NC}"
install_snap thunderbird

echo -e "${GREEN}--> brave...${NC}"
install_flathub "io.github.ungoogled_software.ungoogled_chromium"

echo -e "${GREEN}=== Level 0 Complete! ===${NC}"
