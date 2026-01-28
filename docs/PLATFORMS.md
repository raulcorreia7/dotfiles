# Platform Support

Platform detection, platform-specific features, and how to add support for new platforms.

## Supported Platforms

| Platform | Support | Package Manager | Notes |
|----------|---------|-----------------|-------|
| **Arch Linux** | Full | pacman + paru (AUR) | Primary development platform |
| **macOS** | Full | Homebrew | Intel and Apple Silicon |
| **WSL** | Full | Distribution's package manager | Windows interoperability helpers |
| **Other Linux** | Best effort | Varies | Detection available, limited package support |

## Platform Detection

Functions are defined in `lib/utils.sh` and `os/*.sh` files.

### `is_wsl()` - WSL Detection

Detects if running inside Windows Subsystem for Linux.

**Location**: `lib/utils.sh` (primary), `os/helpers/wsl.sh` (extended)

**Returns**: `0` if in WSL, `1` otherwise

```sh
if is_wsl; then
  echo "Running in WSL"
fi
```

### `is_darwin()` / `is_macos()` - macOS Detection

**Location**: `lib/utils.sh`

**Returns**: `0` if on macOS, `1` otherwise

```sh
if is_darwin; then
  echo "Running on macOS"
fi
```

### `is_linux()` - Linux Detection

Detects native Linux (not WSL, not macOS).

**Location**: `lib/utils.sh`

```sh
if is_linux; then
  echo "Running on native Linux"
fi
```

### `is_arch()` - Arch Linux Detection

**Location**: `lib/utils.sh`

```sh
if is_arch; then
  echo "Running on Arch Linux"
fi
```

### `get_distro()` - Distribution Detection

Gets the Linux distribution ID from `/etc/os-release`.

**Location**: `lib/utils.sh`, `os/helpers/linux.sh` (as `linux_get_distro`)

```sh
distro=$(get_distro)
family=$(linux_get_distro_family)
```

**Supported Families**:

| Family | Distributions |
|--------|--------------|
| `arch` | arch, manjaro, endeavouros, garuda, cachyos |
| `debian` | debian, ubuntu, linuxmint, pop, elementary, zorin, kali, raspbian |
| `rhel` | fedora, rhel, centos, rocky, alma, oracle |
| `suse` | opensuse, suse, sles |
| `alpine` | alpine |

## Platform-Specific Features

### Arch Linux

**Files**: `os/helpers/arch.sh`, `modules/arch/init.sh`

```sh
arch_pacman_update      # Update official packages
arch_paru_update        # Update AUR packages
arch_sys_update         # Update all packages
arch_sys_update_full    # Full maintenance workflow
```

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_ARCH_ASSUME_YES` | `0` | Skip pacman/paru confirmation prompts |

**Package Lists**: `os/install/packages/arch/` (pacman, aur)

### macOS

**File**: `os/install/install-macos.sh`

```sh
# Install macOS packages
./install

# Or directly:
os/install/install-macos.sh [--dry-run] [--category cli] [--no-gui]
```

| Category | File | Description |
|----------|------|-------------|
| `base` | `os/install/packages/macos/base` | Essential packages |
| `cli` | `os/install/packages/macos/cli` | Command-line tools |
| `dev` | `os/install/packages/macos/dev` | Development tools |
| `gui` | `os/install/packages/macos/gui` | GUI applications (casks) |

### WSL

**File**: `os/helpers/wsl.sh`

| Function | Description | Usage |
|----------|-------------|-------|
| `wsl_windows_home()` | Get Windows home directory | `home=$(wsl_windows_home)` |
| `wsl_clipboard_copy()` | Copy stdin to Windows clipboard | `echo "text" \| wsl_clipboard_copy` |
| `wsl_open()` | Open file/URL with Windows default app | `wsl_open file.pdf` |
| `wsl_path_to_win()` | Convert WSL path to Windows path | `winpath=$(wsl_path_to_win "/home/user")` |
| `wsl_path_from_win()` | Convert Windows path to WSL path | `wslpath=$(wsl_path_from_win "C:\\Users")` |

### Other Linux

**File**: `os/helpers/linux.sh`

| Function | Description |
|----------|-------------|
| `linux_has_apt()` | Check for apt |
| `linux_has_pacman()` | Check for pacman |
| `linux_has_dnf()` | Check for dnf/yum |
| `linux_pkg_install()` | Show install command for current distribution |

## OS Helper Functions Reference

| File | Function | Description |
|------|----------|-------------|
| `os/helpers/wsl.sh` | `wsl_detect()` | Confirm running in WSL |
| `os/helpers/wsl.sh` | `wsl_windows_home()` | Get Windows home directory |
| `os/helpers/wsl.sh` | `wsl_clipboard_copy()` | Copy stdin to Windows clipboard |
| `os/helpers/wsl.sh` | `wsl_open()` | Open file/URL with Windows default app |
| `os/helpers/wsl.sh` | `wsl_path_to_win()` | Convert WSL path to Windows path |
| `os/helpers/wsl.sh` | `wsl_path_from_win()` | Convert Windows path to WSL path |
| `os/helpers/arch.sh` | `arch_pacman_update()` | Update official packages |
| `os/helpers/arch.sh` | `arch_paru_update()` | Update AUR packages |
| `os/helpers/arch.sh` | `arch_sys_update()` | Update all packages |
| `os/helpers/arch.sh` | `arch_sys_update_full()` | Full maintenance workflow |
| `os/helpers/linux.sh` | `linux_get_distro()` | Get distribution ID |
| `os/helpers/linux.sh` | `linux_get_distro_family()` | Get distribution family |
| `os/helpers/linux.sh` | `linux_has_apt()` | Check for apt |
| `os/helpers/linux.sh` | `linux_has_pacman()` | Check for pacman |
| `os/helpers/linux.sh` | `linux_has_dnf()` | Check for dnf/yum |
| `os/helpers/linux.sh` | `linux_pkg_install()` | Show install command |

## Feature Flags

| Variable | Default | Description |
|----------|---------|-------------|
| `DOTFILES_ARCH_ASSUME_YES` | `0` | Skip pacman/paru confirmation prompts on Arch |
| `DOTFILES_MISE_INSTALL` | `1` | Enable mise tool installation |
| `DOTFILES_ZIMFW_INSTALL` | `1` | Enable zimfw module setup |
| `DOTFILES_ZIMFW_BUILD` | `1` | Enable zimfw build step |
| `DOTFILES_POST_INSTALL` | `1` | Enable post-install scripts |

## Adding New Platform Support

1. **Create OS Helper**: `os/<platform>.sh` with platform-specific functions
2. **Add Detection**: Add `is_<platform>()` to `lib/utils.sh`
3. **Create Installer**: `os/install/install-<platform>.sh`
4. **Update Main Install**: Add platform to `install` script's detection
5. **Create Package Lists**: `os/install/packages/<platform>/`
6. **Document**: Update this file with the new platform

## Related Files

- `lib/utils.sh` - Core platform detection functions
- `os/helpers/wsl.sh` - WSL-specific helpers
- `os/helpers/linux.sh` - Generic Linux helpers
- `os/helpers/arch.sh` - Arch-specific helpers
- `modules/arch/init.sh` - Arch plugin functions
- `install` - Main install entrypoint with platform detection
- `os/install/install-arch.sh` - Arch package installer
- `os/install/install-macos.sh` - macOS package installer
- `lib/install.sh` - Shared installer utilities
