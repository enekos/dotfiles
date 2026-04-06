# ⚡️ Eneko's Dotfiles

My personal dotfiles for macOS, managed cleanly with GNU Stow. This setup is heavily optimized for terminal power users, featuring a modern Rust-based CLI stack, Neovim (LazyVim), and Starship prompt.

## ✨ Features

- **Shell:** Zsh powered by [Starship](https://starship.rs/) for a blazing fast, cross-shell prompt.
- **Dotfile Manager:** [GNU Stow](https://www.gnu.org/software/stow/) for clean, symlink-based management.
- **Modern CLI Stack:**
  - `fzf` for fuzzy finding.
  - `eza` as a modern replacement for `ls`.
  - `bat` as a syntax-highlighting replacement for `cat`.
  - `fd` as a faster, friendlier `find`.
  - `zoxide` for smarter directory navigation.
- **Git:** Configured with [git-delta](https://github.com/dandavison/delta) for syntax-highlighted, side-by-side diffs, plus a global `.gitignore`.
- **Editor:** Neovim configured via [LazyVim](https://www.lazyvim.org/).

---

## 🚀 Installation

### 1. Prerequisites
Ensure you have [Homebrew](https://brew.sh/) installed on your Mac.

Install the required packages:
```bash
brew install stow starship fzf eza bat fd git-delta zoxide
```

### 2. Clone the Repository
Clone this repository into your home directory:
```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 3. Setup Secrets (Important 🔒)
For security, API keys and access tokens are **not** committed to this repository.
Before starting your shell, create a `~/.zsecrets` file in your home directory:

```bash
touch ~/.zsecrets
chmod 600 ~/.zsecrets
```

Add your personal exports to this file (e.g., DigitalOcean, Hetzner, Gemini tokens):
```bash
# ~/.zsecrets example
export DO_TOKEN="your_token_here"
export GEMINI_API_KEY="your_api_key_here"
```
*Note: Your `.zshrc` is configured to automatically source this file if it exists.*

### 4. Symlink with Stow
Use GNU Stow to symlink the configurations into your home directory. Run this from inside the `~/dotfiles` directory:

```bash
stow zsh
stow git
stow nvim
```

To install everything at once:
```bash
stow */
```

Restart your terminal, and you're good to go! 🎉

---

## 🛠️ How to Manage Dotfiles with Stow

GNU Stow works by mirroring the directory structure of the package into the target directory (by default, the parent directory `~/`).

### Adding a new configuration
If you want to add a new tool, say `tmux`, follow these steps:

1. Create a folder for it in the dotfiles repo:
   ```bash
   mkdir -p ~/dotfiles/tmux
   ```
2. Move your existing config into that folder, preserving the expected path relative to your home directory:
   ```bash
   mv ~/.tmux.conf ~/dotfiles/tmux/
   ```
3. Run stow to create the symlink:
   ```bash
   cd ~/dotfiles
   stow tmux
   ```

### Removing a configuration
To remove the symlinks for a specific package, use the `-D` (delete) flag:
```bash
stow -D zsh
```

## 📁 Repository Structure
```text
~/dotfiles
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── nvim/
│   └── .config/
│       └── nvim/        # LazyVim setup
└── zsh/
    └── .zshrc
```
