# Arch Linux Work Laptop Setup

This repository contains the configurations and restoration script to quickly set up a lightweight version of MatricalDefunkt's Arch Linux workstation on a new laptop.

## 🚀 Quick Start

Once you have installed Arch Linux (e.g., using `archinstall` with KDE Plasma), open your terminal and run:

```bash
git clone https://github.com/MatricalDefunkt/arch-work-setup.git
cd arch-work-setup
chmod +x recreate-system.sh
./recreate-system.sh
```

---

## 🛠️ What the Script Does

1.  **Optimizes Pacman**: Enables `ParallelDownloads = 5` and the `multilib` repository.
2.  **Installs Native Packages**: Core tools (`git`, `zsh`, `kitty`, `starship`, `eza`, `bat`, `fzf`, `jq`, `ripgrep`, `btop`, `fastfetch`), DevOps environments (`docker`, `podman`, `kubectl`, `kubeadm`, `minikube`, `helm`, `terraform`, `packer`), and runtimes (`go`, `python`, `rustup`, `dotnet-sdk`, `jdk17-openjdk`).
3.  **Installs AUR Helper & Packages**: Installs `yay`, and uses it to install VS Code (`visual-studio-code-bin`), Wireguard UI (`wireguird`), `podman-desktop`, `dnslookup-bin`, `nvm`, and CLI assets.
4.  **Restores Shell & Environment**: Installs Oh My Zsh and plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`).
5.  **Restores Dotfiles**: Links Kitty terminal config, Starship theme, Zsh profile (with optimized lazy-loaded runtimes), fastfetch, Git profiles (`.gitconfig*`), and SSH config.
6.  **Installs VS Code Extensions**: Auto-installs extensions specified in `vscode-extensions.txt`.
7.  **Enables Services**: Starts and configures NetworkManager, Docker, and Podman services.

---

## 🔑 Post-Installation Manual Steps

Since private keys and secrets should not be uploaded to a public repository, you must restore them manually from your backup:

1.  **SSH Private Keys**: Copy your private keys (`aur_ed25519`, `matdef_aur`, `pramit.pem`, etc.) to `~/.ssh/` and set proper permissions (`chmod 600 ~/.ssh/*`).
2.  **GPG Keys**: Import your GPG private keys (`gpg --import <key_file>`) so you can sign commits and access encrypted databases.
3.  **Credentials**: Copy `~/.git-credentials-mobigic` to restore credentials for Mobigic git repos.
4.  **Password Store**: Copy `~/.password-store/` to recover your password vaults.
5.  **Re-enable Shell Secrets**: Edit `~/.zshrc` and fill in:
    *   `export VULTR_API_KEY="..."`
    *   `export BW_SESSION="..."`
