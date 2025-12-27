#!/bin/bash
set -e

# Ensure we can find lib.sh
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "$SCRIPT_DIR/lib.sh"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}=== Level 1: Development Environment Setup ===${NC}"

echo -e "${BLUE}--> Installing Rust (Rustup)...${NC}"
if ! command -v rustup &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source env immediately for this script session
    source "$HOME/.cargo/env"
else
    echo "Rustup already installed."
    rustup update
fi

echo -e "${BLUE}--> Installing Dotnet SDK...${NC}"
install_apt "dotnet-sdk-8.0"
install_apt "dotnet-sdk-9.0"
install_apt "dotnet-sdk-10.0"

echo -e "${BLUE}--> Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sudo sh
    # Add user to docker group so you don't need sudo
    sudo usermod -aG docker "$USER"
    echo "  [!] You will need to logout/login for Docker permissions to take effect."
else
    echo "Docker already installed."
fi


echo -e "${BLUE}--> Installing Cloud Tools...${NC}"
if ! is_installed "azure-cli"; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
    echo "az-cli already installed"
fi

if ! command -v terraform &> /dev/null; then
    echo "Setting up HashiCorp Repo for Terraform..."
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

    # FIX: Hardcode 'noble' because 'questing' repo doesn't exist yet
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update && install_apt terraform
else
    echo "Terraform already installed."
fi

if ! command -v flatpak &> /dev/null; then
    echo "Installing Flatpak..."
    sudo apt install -y flatpak plasma-discover-backend-flatpak
    # Add Flathub repo immediately
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

echo -e "${BLUE}--> Installing Chat & Social...${NC}"
install_flathub "dev.vencord.Vesktop"
install_flathub "com.github.IsmaelMartinez.teams_for_linux"
install_apt "btop"

echo -e "${BLUE}--> Preparing Emacs Build (Wayland/PGTK + Native Comp)...${NC}"

if ! command -v emacs &> /dev/null; then

    sudo sed -i 's/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/ubuntu.sources
    sudo apt update

    # Install Build Dependencies
    echo "Installing build dependencies..."
    sudo apt build-dep -y emacs
    # libgccjit is crucial for --with-native-compilation
    # libgtk-3-dev is crucial for --with-pgtk
    install_apt libgccjit-$(gcc -dumpversion)-dev
    install_apt libjansson-dev
    install_apt libtree-sitter-dev
    install_apt gcc-13
    install_apt libgccjit-13-dev

    mkdir -p "$HOME/opensource"

    # Clone Repo
    if [ ! -d "$HOME/opensource/emacs-src" ]; then
        git clone --depth 1 -b emacs-30 git://git.savannah.gnu.org/emacs.git "$HOME/opensource/emacs-src"
    fi

    cd "$HOME/opensource/emacs-src"

    # Configure
    # PGTK = Pure GTK (No X11 calls, perfect for Wayland)
    # Native Comp = Compiles Elisp to native machine code (FAST)
    echo "Configuring Emacs..."
    ./autogen.sh
    ./configure \
      --with-pgtk \
      --with-native-compilation \
      --with-tree-sitter \
      --with-json \
      --with-gnutls \
      --with-modules \
      CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer"

    # Build & Install
    echo "Compiling Emacs... grab a ☕"
    make -j$(nproc)
    sudo make install

    cd ~
else
    echo "Emacs already installed."
fi

echo -e "${GREEN}=== Level 1 Complete! ===${NC}"
echo -e "Note: Docker group changes require a logout/login."
