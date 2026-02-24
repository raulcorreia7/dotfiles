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
