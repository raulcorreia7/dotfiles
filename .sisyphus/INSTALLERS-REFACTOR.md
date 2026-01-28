# Installers Refactor - 2024-01-28

## Summary

Refactored all OS installers with consistent features while keeping the package structure simple (KISS).

---

## Consistent Features (All Installers)

| Feature | Arch | macOS | Windows |
|---------|------|-------|---------|
| `--dry-run` / `-DryRun` | ✅ | ✅ | ✅ |
| Better summary | ✅ | ✅ | ✅ |
| Skip installed | ✅ | ✅ | ✅ |
| Error handling | ✅ | ✅ | ✅ |

---

## Package Structure (KISS)

### Arch Linux
```
packages/arch/
├── pacman    # All official packages (single file)
└── aur       # All AUR packages (single file)
```

Simple, just two files as requested.

### Windows
```
packages/windows/
└── packages  # All packages (single file)
```

Single file for simplicity.

### macOS
```
packages/macos/
├── base        # Core dependencies
├── cli         # Command line tools
├── development # Dev tools
└── gui         # GUI apps
```

Kept categories because Homebrew Brewfiles work better this way (different format).

---

## Usage Examples

### Arch Linux
```bash
# Install everything
./installers/install-arch.sh

# Preview what would be installed (dry run)
./installers/install-arch.sh --dry-run

# Skip AUR packages
./installers/install-arch.sh --no-aur

# Show help
./installers/install-arch.sh --help
```

### macOS
```bash
# Install everything
./installers/install-macos.sh

# Preview (dry run)
./installers/install-macos.sh --dry-run

# Skip GUI apps
./installers/install-macos.sh --no-gui

# Install only specific category
./installers/install-macos.sh --category cli
```

### Windows
```powershell
# Install everything
.\installers\install-windows.ps1

# Preview (dry run)
.\installers\install-windows.ps1 -DryRun

# Show help
.\installers\install-windows.ps1 -Help
```

---

## Summary Output Example

```
=== Summary ===
Mode: DRY RUN (if applicable)
Installed: 5
Skipped: 45 (already installed)
Failed: 0
```

---

## Design Principles

1. **KISS**: Simple package files (no over-categorization)
2. **Consistent**: Same options across all installers
3. **Informative**: Clear summary of what happened
4. **Safe**: Dry-run mode to preview changes
