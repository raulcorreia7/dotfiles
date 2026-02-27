# Scripting Examples

## Good Script Header

```bash
#!/usr/bin/env bash
# sync-backup.sh - Sync local data to backup server
#
# Usage: sync-backup.sh [OPTIONS]
#   -d, --dry-run    Show what would be synced
#   -v, --verbose    Enable verbose output
#   -h, --help       Show this help
#
# Requirements: rsync, ssh
#
# Environment:
#   BACKUP_HOST   (required) Backup server hostname
#   BACKUP_PATH   (optional) Remote path (default: /backup)
```

## Python Script Pattern

```python
#!/usr/bin/env python3
"""
Process data files and generate reports.

Usage: process.py <input_dir> [options]
"""

import argparse
import sys
from pathlib import Path

def main():
    args = parse_args()
    if not validate(args):
        sys.exit(1)
    # ... logic ...

if __name__ == "__main__":
    main()
```

## zx (TypeScript) Script Pattern

```typescript
#!/usr/bin/env zx

// backup-files.mjs - Backup important files
// Usage: ./backup-files.mjs

await $`mkdir -p backups`
await $`cp -r src backups/`
await $`tar czf backup-$(date +%Y%m%d).tar.gz backups/`

echo('Backup complete')
```

## POSIX Argument Parsing (Bash)

```bash
#!/usr/bin/env bash
# deploy.sh - Deploy application to environment
#
# Usage: deploy.sh [OPTIONS] <environment>
#   -c, --config FILE    Config file path (default: config.yaml)
#   -o, --output DIR     Output directory (default: ./dist)
#   -v, --verbose        Enable verbose output
#   -q, --quiet          Suppress non-error output
#   -h, --help           Show this help

set -euo pipefail

config="config.yaml"
output="./dist"
verbose=false
quiet=false

usage() {
    sed -n 's/^# //p' "$0" | head -n 12
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)  config="$2"; shift 2 ;;
        -o|--output)  output="$2"; shift 2 ;;
        -v|--verbose) verbose=true; shift ;;
        -q|--quiet)   quiet=true; shift ;;
        -h|--help)    usage ;;
        --)           shift; break ;;
        *)            break ;;
    esac
done

environment="${1:-}"
[[ -z "$environment" ]] && { echo "error: environment required" >&2; exit 1; }
```
