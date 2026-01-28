# AGENTS.md — Dotfiles Development Contract

> **Note**: This file has been moved. The authoritative version is now at [`docs/development/AGENTS.md`](docs/development/AGENTS.md).
>
> Please update your bookmarks.

---

## Quick Links

- **[Full Development Guide](docs/development/AGENTS.md)** — Complete coding standards, workflows, and conventions
- **[Reference Documentation](docs/reference/)** — API reference and configuration docs

---

## Overview

This repository contains personal dotfiles managed with a modular, maintainable approach.

**Entry Point**: `init.sh` — sourced by shell config  
**Languages**: Shell (POSIX sh, zsh), some PowerShell

### Repository Structure

```
.dotfiles/
├── config/          # App configs + shell modules
├── lib/install/     # Installation helpers
├── os/install/      # OS-specific installers
│   ├── lib/         # Shared libraries
│   ├── before/      # Pre-install hooks
│   ├── modules/     # Modular components
│   ├── os/          # OS-specific installers
│   └── after/       # Post-install hooks
├── bin/             # User scripts
├── docs/            # Documentation
│   ├── development/ # Developer guides
│   └── reference/   # Reference docs
└── init.sh          # Shell entrypoint
```

See the [full documentation](docs/development/AGENTS.md) for detailed conventions, naming standards, and workflows.
