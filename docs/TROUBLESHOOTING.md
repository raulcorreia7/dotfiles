# Troubleshooting

Quick fixes for common dotfiles issues.

## Quick Reference

| Issue | Command |
|-------|---------|
| Check health | `rdotfiles health` |
| Fix all issues | `rdotfiles fix --all` |
| Fix links | `rdotfiles fix --link` |
| Fix zimfw | `rdotfiles fix --zimfw` |
| Debug startup | `DOTFILES_DEBUG=1 zsh -i` |
| Time startup | `hyperfine 'zsh -i -c exit'` |

---

## Shell Startup

**Slow startup**
```bash
hyperfine --warmup 3 'zsh -i -c exit'          # Benchmark
DOTFILES_DEBUG=1 zsh -i -c exit 2>&1 | head -50  # Debug
```

**Mise not loading**
```bash
type mise              # Check lazy-load status (shows: mise is a shell function)
mise --version         # Force load
export DOTFILES_MISE_LAZY=0  # Disable lazy loading
```

**Plugin not loading**
```bash
env | grep DOTFILES_ENABLE  # Check enabled plugins
```

Disable plugins in `~/.zshenv`:
```bash
export DOTFILES_ENABLE_FZF=0
export DOTFILES_ENABLE_TMUX=0
export DOTFILES_ENABLE_ZOXIDE=0
export DOTFILES_ENABLE_MISE=0
export DOTFILES_ENABLE_ZIMFW=0
export DOTFILES_ENABLE_ARCH=0
```

---

## Link Issues

**Broken symlinks**
```bash
rdotfiles health       # Check
rdotfiles fix --link   # Auto-fix

# Manual fix
rm ~/.config/nvim
ln -s ~/.dotfiles/config/nvim ~/.config/nvim
```

**Config files not found**
```bash
echo "XDG_CONFIG_HOME=$XDG_CONFIG_HOME"  # Should be $HOME/.config
export XDG_CONFIG_HOME="$HOME/.config"   # Fix
```

**Scripts not in PATH**
```bash
echo "$PATH" | tr ':' '\n' | grep "\.local/bin"  # Check
export PATH="$HOME/.local/bin:$PATH"              # Fix
rdotfiles link                                     # Re-run linker
```

---

## Zimfw Issues

**Modules missing / init stale**
```bash
rdotfiles fix --zimfw                              # Auto-fix
zsh -c '. "$ZIM_HOME/zimfw.zsh" build'            # Manual rebuild
```

**Zimfw not found**
```bash
ls -la ~/.zim/zimfw.zsh                            # Check install
rdotfiles fix --zimfw-install                      # Install
echo "ZIM_HOME=$ZIM_HOME"                          # Should be $HOME/.zim
```

---

## Platform Issues

**WSL: Path conversion**
```bash
wsl_path_to_win /home/user/project                 # WSL to Windows
wsl_path_from_win 'C:\Users\Name\file.txt'        # Windows to WSL
```

**macOS: PATH issues**
```bash
echo "$PATH" | grep -E "(opt/homebrew|usr/local)"  # Check Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"          # Apple Silicon fix
```

**Arch: pacman/paru not found**
```bash
echo "DOTFILES_ENABLE_ARCH=$DOTFILES_ENABLE_ARCH"  # Check enabled
# Install paru manually
git clone https://aur.archlinux.org/paru.git /tmp/paru
cd /tmp/paru && makepkg -si
```

---

## Debug Mode

**Enable debug output**
```bash
DOTFILES_DEBUG=1 zsh -i         # One-time
export DOTFILES_DEBUG=1         # Full session
```

**Expected output:**
```
dotfiles: source /home/user/.dotfiles/config/paths.sh
dotfiles: source /home/user/.dotfiles/lib/loader.sh
dotfiles: mise loading via precmd
```

**Report issues with:**
```bash
echo "=== Debug ==="
DOTFILES_DEBUG=1 zsh -i -c exit 2>&1

echo "=== Environment ==="
env | grep -E "^(DOTFILES|XDG|ZIM|HOME|PATH)" | sort

echo "=== Health ==="
rdotfiles health
```
