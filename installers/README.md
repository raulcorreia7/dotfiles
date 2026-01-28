# installers/

Installation scripts for dotfiles.

## Scripts

| Script | Purpose |
|--------|---------|
| `link.sh` | Symlink configs to `~/.config/` and bin to `~/.local/bin/` |
| `lib.sh` | Shared helper functions (read_packages, log, etc.) |
| `config.sh` | Shared configuration variables |
| `install-arch.sh` | Install packages on Arch Linux (pacman/paru) |
| `install-macos.sh` | Install packages on macOS (brew bundle) |
| `install-windows.ps1` | Install packages on Windows (winget/choco/scoop) |
| `post-install.sh` | Post-install setup (git config, XDG dirs, etc.) |

## Usage

### Quick Install

Run the main install script from repo root:

```bash
./install
```

### Link Only

If you only want to link configs without installing packages:

```bash
installers/link.sh
```

### OS-Specific Install

#### Arch Linux

```bash
# Install all packages (pacman + AUR)
installers/install-arch.sh

# Preview what would be installed (dry run)
installers/install-arch.sh --dry-run

# Skip AUR packages
installers/install-arch.sh --no-aur

# Show help
installers/install-arch.sh --help
```

#### macOS

```bash
# Install all packages
installers/install-macos.sh

# Preview what would be installed
installers/install-macos.sh --dry-run

# Skip GUI applications
installers/install-macos.sh --no-gui

# Install specific category only
installers/install-macos.sh --category cli
```

#### Windows

```powershell
# Install all packages
.\installers\install-windows.ps1

# Preview what would be installed
.\installers\install-windows.ps1 -DryRun

# Show help
.\installers\install-windows.ps1 -Help
```

## Package Files

Package lists are stored in `installers/packages/`:

### Arch Linux

- `packages/arch/pacman` — Official repository packages
- `packages/arch/aur` — AUR packages

### macOS

- `packages/macos/base` — Core dependencies
- `packages/macos/cli` — Command line tools
- `packages/macos/development` — Development tools
- `packages/macos/gui` — GUI applications

### Windows

- `packages/windows/packages` — All packages (single file)

## Features

All installers support:

- **Dry-run mode**: Preview what would be installed without making changes
- **Skip installed**: Automatically skip packages already installed
- **Summary**: Show count of installed/skipped/failed packages
- **Error handling**: Continue on individual package failures

## Adding OS Packages

Edit the appropriate package file for your OS, then run the installer.

Format: One package per line, comments with `#`:

```
# Core tools
fzf
git
fd
```
