# Installation Reference

## Scripts

| Script | Location | Purpose |
|--------|----------|---------|
| `link.sh` | `lib/install/` | Symlink configs to `~/.config/`, bin to `~/.local/bin/` |
| `lib.sh` | `lib/install/` | Shared helper functions |
| `config.sh` | `lib/install/` | Shared configuration variables |
| `arch.sh` | `os/install/` | Arch Linux packages (pacman/paru) |
| `macos.sh` | `os/install/` | macOS packages (brew) |
| `windows.ps1` | `os/install/` | Windows packages (winget/choco/scoop) |
| `post-install.sh` | `lib/install/` | Post-install setup |

## Usage

### Quick Install

```bash
./install       # Main installer
```

### Link Only

```bash
lib/install/link.sh
# or
rdotfiles link
```

### OS-Specific

**Arch Linux:**
```bash
os/install/arch.sh           # Install all
os/install/arch.sh --dry-run # Preview
os/install/arch.sh --no-aur  # Skip AUR
```

**macOS:**
```bash
os/install/macos.sh              # Install all
os/install/macos.sh --dry-run    # Preview
os/install/macos.sh --no-gui     # Skip GUI apps
os/install/macos.sh --category cli
```

**Windows:**
```powershell
os/install/windows.ps1
os/install/windows.ps1 -DryRun
```

## Package Files

| OS | Location |
|----|----------|
| Arch | `lib/install/packages/arch/pacman`, `lib/install/packages/arch/aur` |
| macOS | `lib/install/packages/macos/{base,cli,development,gui}` |
| Windows | `lib/install/packages/windows/packages` |

Format: One package per line, comments with `#`.

## Features

- **Dry-run mode**: Preview without changes
- **Skip installed**: Auto-skip existing packages
- **Summary**: Show installed/skipped/failed counts
- **Error handling**: Continue on individual failures
