#!/bin/bash
set -e

# Recreate System Script for Arch Linux (Work Laptop)
# MatricalDefunkt Setup

echo "========================================================================="
echo " Starting System Recreation Setup"
echo "========================================================================="

# Get the directory of the script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Optimize Pacman
echo "Optimizing Pacman configurations..."
# Enable ParallelDownloads in /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf || true
if ! grep -q '^ParallelDownloads' /etc/pacman.conf; then
    echo "ParallelDownloads = 5" | sudo tee -a /etc/pacman.conf
fi
# Enable multilib repo
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf

# 2. Update and Install Core/Native Packages
echo "Updating packages and installing native packages..."
sudo pacman -Syu --needed --noconfirm \
    base-devel git zsh kitty starship eza bat fzf jq ripgrep btop fastfetch wl-clipboard rsync wget curl net-tools \
    docker podman kubectl kubeadm minikube helm terraform packer go python rustup dotnet-sdk jdk17-openjdk \
    wireguard-tools ttf-firacode-nerd networkmanager network-manager-applet networkmanager-openvpn

# 3. Install YAY (AUR Helper)
if ! command -v yay &> /dev/null; then
    echo "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# 4. Install AUR Packages
echo "Installing AUR packages..."
yay -S --needed --noconfirm \
    visual-studio-code-bin wireguird podman-desktop dnslookup-bin nvm pokemon-colorscripts-go

# 5. Restore Oh My Zsh and plugins
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 6. Restore Dotfiles
echo "Restoring dotfiles..."
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/fastfetch"
mkdir -p "$HOME/.ssh"

cp "$SCRIPT_DIR/dotfiles/.zshrc" "$HOME/.zshrc"
cp "$SCRIPT_DIR/dotfiles/starship.toml" "$HOME/.config/starship.toml"
cp "$SCRIPT_DIR/dotfiles/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp "$SCRIPT_DIR/dotfiles/.config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
cp "$SCRIPT_DIR/dotfiles/.gitconfig" "$HOME/.gitconfig"
cp "$SCRIPT_DIR/dotfiles/.gitconfig-projects" "$HOME/.gitconfig-projects"
cp "$SCRIPT_DIR/dotfiles/.gitconfig-codex" "$HOME/.gitconfig-codex"
cp "$SCRIPT_DIR/dotfiles/.gitconfig-work" "$HOME/.gitconfig-work"
cp "$SCRIPT_DIR/dotfiles/.gitconfig-mobigic" "$HOME/.gitconfig-mobigic"
cp "$SCRIPT_DIR/dotfiles/.ssh/config" "$HOME/.ssh/config"

# Fix SSH config permissions
chmod 600 "$HOME/.ssh/config"

# 7. Install VS Code Extensions
if [ -f "$SCRIPT_DIR/vscode-extensions.txt" ] && command -v code &>/dev/null; then
    echo "Installing VS Code extensions..."
    while read -r ext; do
        if [ -n "$ext" ]; then
            code --install-extension "$ext" --force
        fi
    done < "$SCRIPT_DIR/vscode-extensions.txt"
fi

# 8. Setup & Start System Services
echo "Configuring services..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now docker
sudo systemctl enable --now podman

# 9. Change default shell to zsh
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
fi

echo "========================================================================="
echo " System Recreation Setup Complete!"
echo "========================================================================="
echo "IMPORTANT manual actions required to restore sensitive data:"
echo "1. Copy private SSH keys to ~/.ssh/ (e.g. aur_ed25519, matdef_aur, pramit.pem)"
echo "2. Import your GPG private keys for commit signing and credentials"
echo "3. Copy your password manager data (~/.password-store/)"
echo "4. Copy git credentials (~/.git-credentials-mobigic)"
echo "5. Add your API keys back into ~/.zshrc (VULTR_API_KEY, BW_SESSION)"
echo "========================================================================="
