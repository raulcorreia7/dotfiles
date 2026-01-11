# Packages

Homebrew packages organized by category for modular installation.

## Structure

```
packages/brew/
├── Brewfile            # Complete system (combines all)
├── Brewfile.base       # Core dotfiles dependencies
├── Brewfile.cli        # Command line utilities
├── Brewfile.development  # Development tools & languages
└── Brewfile.gui        # GUI applications
```

## Installation

### Complete System
Install everything:
```sh
brew bundle --file=packages/brew/Brewfile
```

### By Category
Install specific categories:
```sh
# Only core dotfiles dependencies
brew bundle --file=packages/brew/Brewfile.base

# Core + CLI utilities
brew bundle --file=packages/brew/Brewfile.base
brew bundle --file=packages/brew/Brewfile.cli

# Core + CLI + Development
brew bundle --file=packages/brew/Brewfile.base
brew bundle --file=packages/brew/Brewfile.cli
brew bundle --file=packages/brew/Brewfile.development

# GUI applications only
brew bundle --file=packages/brew/Brewfile.gui
```

### For New Machines
Quick minimal setup (base + cli):
```sh
cd ~/personal/dotfiles
brew bundle --file=packages/brew/Brewfile.base
brew bundle --file=packages/brew/Brewfile.cli
```

## Categories

### Brewfile.base
Core dependencies required for dotfiles to function:
- fzf (fuzzy finder)
- git (version control)
- fd, ripgrep, bat, eza (modern CLI tools)
- jq (JSON processor)

### Brewfile.cli
Command line utilities and tools:
- System monitoring (btop, fastfetch)
- File operations (tree, rsync, p7zip)
- Network (wget, curlie)
- Shell enhancement (starship, zellij)
- Documentation (tldr, glow)
- Optional tools (commented out)

### Brewfile.development
Development tools, languages, and infrastructure:
- Version control (git-delta, gh, lazygit)
- Editors (neovim)
- Languages (rust, go, node, python)
- Build tools (cmake, make, ninja)
- Cloud & infra (awscli, terraform, helm)
- Quality tools (shellcheck, shfmt)

### Brewfile.gui
GUI applications:
- Terminal (ghostty)
- Editors (vscode)
- Productivity (rectangle, alt-tab, obsidian)
- Browsers (firefox, chrome)
- Development tools (docker, github)
- Communication (teams, chatgpt)

## Adding New Packages

1. Choose appropriate category file
2. Add package under relevant section header
3. Reinstall category:
   ```sh
   brew bundle --file=packages/brew/Brewfile.<category>
   ```

## Updating Packages

Update all packages:
```sh
brew update && brew upgrade
```

Update and check for outdated:
```sh
brew outdated
```

Clean up old versions:
```sh
brew cleanup
```

## Notes

- **Brewfile.development** and **Brewfile.gui** include base dependencies
- Optional tools are commented out with explanations
- Uncomment as needed when you require those tools
