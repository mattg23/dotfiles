#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/lib.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Level 2: Customization & make it home ===${NC}"

echo -e "${BLUE}--> Installing Fonts...${NC}"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
    echo "Downloading MesloLGS NF..."
    wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    wget -P "$FONT_DIR" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
else
    echo "Nerd Fonts already installed."
fi

if [ ! -f "$FONT_DIR/FiraCodeNerdFont-Regular.ttf" ]; then
    echo "Downloading Fira Code Nerd Font..."
    # Grab the latest release zip
    wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip -o /tmp/FiraCode.zip -d "$FONT_DIR"
    rm /tmp/FiraCode.zip
fi

if [ ! -f "$FONT_DIR/Iosevka-Regular.ttf" ]; then
    echo "Downloading Iosevka..."
    # Using a specific stable version (29.0.4) to prevent link rot
    wget -O /tmp/Iosevka.zip https://github.com/be5invis/Iosevka/releases/download/v33.3.6/PkgTTC-Iosevka-33.3.6.zip
    unzip -o /tmp/Iosevka.zip -d "$FONT_DIR"
    rm /tmp/Iosevka.zip
fi


install_apt "fonts-noto-color-emoji"

echo "Rebuilding font cache..."
fc-cache -f -v > /dev/null

echo -e "${BLUE}--> Configuring KDE Session Restore...${NC}"
kwriteconfig6 --file ksmserverrc --group General --key loginMode "restorePreviousLogout"

# ZSH magic

echo -e "${GREEN}--> setting up Oh-My-Zsh...${NC}"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    sudo usermod --shell "$(which zsh)" "$USER"
else
    echo "Oh-My-Zsh is already installed."
fi

# C. Install Powerlevel10k Theme
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Cloning Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

# D. Install Essential Plugins (Autosuggestions & Syntax Highlighting)
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Input Method (Fcitx5)
echo -e "${BLUE}--> Configuring Input Method (Fcitx5)...${NC}"
# Install the packages
install_apt "fcitx5"
install_apt "fcitx5-frontend-gtk4"
install_apt "fcitx5-frontend-qt6"
install_apt "kde-config-fcitx5"

if ! is_installed "im-emoji-picker"; then
    echo "Downloading GaZaTu im-emoji-picker..."
    PICKER_URL="https://github.com/GaZaTu/im-emoji-picker/releases/download/v1.1.1/im-emoji-picker-x86_64-ubuntu-25.04-fcitx5.deb"

    tmpdeb=$(mktemp /tmp/emoji-picker.XXXXX.deb)
    # Ensure cleanup
    trap 'rm -f "$tmpdeb"' EXIT

    curl -fsSL "$PICKER_URL" -o "$tmpdeb"

    echo "Installing Emoji Picker..."
    sudo apt install -y "$tmpdeb"

    # fcitx5 searches in a different folder
    sudo ln -s /usr/lib/fcitx5/fcitx5imemojipicker.so /usr/lib/x86_64-linux-gnu/fcitx5/fcitx5imemojipicker.so
else
    echo "im-emoji-picker is already installed."
fi

# Set Fcitx5 as the active input method
im-config -n fcitx5
# Ensure Wayland knows about it
kwriteconfig6 --file kwinrc --group Wayland --key InputMethod "/usr/share/applications/org.fcitx.Fcitx5.desktop"

echo -e "${BLUE}--> Updating /etc/environment for Fcitx5...${NC}"

# Check if one of them exists to avoid duplicates
if ! grep -q "GTK_IM_MODULE=fcitx" /etc/environment; then
    echo "Adding IM environment variables to /etc/environment..."
    # sudo tee -a allows us to append to a root-owned file
    cat <<EOF | sudo tee -a /etc/environment > /dev/null
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
EOF
else
    echo "Environment variables already present in /etc/environment."
fi

echo -e "${GREEN}--> Creating Home Directory Structure...${NC}"
# -p ensures no error if folders already exist
mkdir -p "$HOME/work" \
         "$HOME/dev" \
         "$HOME/opensource" \
         "$HOME/dump" \
         "$HOME/private" \
         "$HOME/scans" \
         "$HOME/company"

# Disable the 30s Shutdown/Logout Confirmation
kwriteconfig6 --file ksmserverrc --group General --key confirmLogout false

echo -e "${GREEN}=== Level 2 Complete! ===${NC}"
