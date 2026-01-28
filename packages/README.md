# packages/

Package lists for automated installation.

## Format

One package per line. Comments start with `#`:

```
# Core utilities
git
curl
wget

# Search tools
fzf
fd
ripgrep
```

## Structure

```
packages/
├── arch/
│   ├── pacman     # Official repository packages
│   └── aur        # AUR packages
├── macos/
│   ├── base       # Core dependencies
│   ├── cli        # Command line tools
│   ├── development # Development tools
│   └── gui        # GUI applications
└── windows/
    └── packages   # All packages (single file)
```

## OS-Specific Notes

### Arch Linux

Two separate files:
- `pacman` — Official repository packages (installed via `pacman`)
- `aur` — AUR packages (installed via `paru`)

The installer will bootstrap `paru` if not present.

### macOS

Uses Homebrew bundle format (Brewfile). Supports:
- Regular packages: `package_name`
- Cask apps: `cask "app-name"`

Categories:
- `base` — Essential dependencies for dotfiles
- `cli` — Command line utilities
- `development` — Development tools and languages
- `gui` — GUI applications (install with `--no-gui` to skip)

### Windows

Single file with package names. The installer tries multiple sources:
1. Chocolatey (`choco`)
2. Scoop (`scoop`)
3. Winget (`winget`)

## Adding Packages

1. Edit the appropriate file for your OS
2. One package per line
3. Use comments to organize by category
4. Run the installer to apply

## How It Works

Installers read these files and:

- Filter out comments and blank lines
- Check if package is already installed
- Install only missing packages
- Show summary of installed/skipped/failed
