# Auto Setup Linux Terminal

## Table of Contents
- [Preview](#preview)
	- [Screenshots](#screenshots)
- [Important Notes](#important-notes)
- [Installation](#installation)
	- [Arch-based Distributions](#arch-based-distributions)
	- [Debian-based Distributions](#debian-based-distributions)
- [Dotfiles Repo](#dotfiles-repo)

## Preview
### Screenshots
![screenshot1](https://github.com/user-attachments/assets/feaef7fc-3464-41c7-a9b5-fd2883c4290e)
![screenshot2](https://github.com/user-attachments/assets/20f92535-983f-4f3d-9772-5f79ced80a54)

## Important Notes
> [!IMPORTANT]
> Make sure you use **Nerd Fonts**.

> [!IMPORTANT]
> Install a backup tool and create a system backup before using this script.

> [!NOTE]
> This script does not include package uninstallation, as some packages may already exist on your system by default. Creating an uninstallation script could potentially affect your current setup.

> [!NOTE]
> The setup installs `~/neofetch-random.sh`, used by the dotfiles shell config to show a random Fastfetch image when the terminal opens.
> It reads the same asset config used by the dotfiles: `~/.local/share/anto426/sync.env`.
> Set `ANTO426_REMOTE_ASSETS_DIR` for a Google Drive/local sync folder, or `ANTO426_NEOFETCH_DIR` to use a different Fastfetch image directory.

## Installation
### Arch-based Distributions
*Example: Arch Linux, EndeavourOS, Manjaro, etc.*
``` bash
sudo pacman -Syu --noconfirm
bash -c "$(curl -fSL https://raw.githubusercontent.com/Anto426/auto-setup-LT/main/arch.sh)"
```

To test a fork or local mirror, override `DOTFILES_REPO` before running the script.

### Debian-based Distributions
*Example: Ubuntu, Kali Linux, Linux Mint, etc.*
``` bash
sudo apt update && sudo apt upgrade -y
bash -c "$(curl -fSL https://raw.githubusercontent.com/Anto426/auto-setup-LT/main/debian.sh)"
```

## Dotfiles Repo
This repo contains all my dotfiles: [`dotfiles`](https://github.com/Anto426/dotfiles).

## Feedback
If you find this repo useful or have any suggestions, feel free to open an issue or submit a pull request.
