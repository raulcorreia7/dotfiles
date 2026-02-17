# Script Rules

## Philosophy
- Self-contained: scripts run independently with minimal external setup
- Clean and intuitive: purpose and usage obvious from the file alone
- Modular: one concern per script; compose when needed
- Organized: consistent structure, naming, and exit behavior

## Language Selection
- Use system languages (shell/bash) for simple orchestration and glue
- Use non-system languages (Python, Node, Go) when:
  - Complex logic or data manipulation is required
  - Better libraries exist for the task
  - Error handling, testing, or maintainability benefit significantly
- Prefer the language already used in similar scripts in the codebase

## Dependencies
- Prefer battle-tested, well-maintained tools and libraries
- Check for existing project dependencies before adding new ones
- Document dependencies in the script header or a requirements file
- Use standard library first; add external deps only for clear value
- Pin versions in requirements files; avoid floating versions

## Structure
- Header: purpose, usage, dependencies, author/date if relevant
- Configuration: constants and env vars at the top
- Functions: small, single-responsibility, named by action
- Main: clear entry point; guard clauses for early exits
- Exit codes: 0 for success, non-zero for specific failures

## Help (Required for User-Facing Scripts)
- All user-facing scripts MUST provide help via `-h`/`--help`
- Help must include: brief description, usage syntax, options/flags, examples
- Non-trivial scripts should also list requirements and environment variables
- Internal/automation-only scripts may omit help but should still have a clear header

## Independence
- Scripts are independent modules by default
- Explicitly declare inputs (args, env vars, config files)
- Explicitly declare outputs (stdout, files, exit codes)
- Avoid implicit dependencies on global state or external services
- When integrating with a larger system:
  - Follow existing architecture patterns
  - Use shared config/contracts where appropriate
  - Document integration points clearly

## Error Handling
- Fail fast with actionable error messages
- Validate inputs early
- Use appropriate exit codes
- Log or print errors to stderr
- Handle missing dependencies gracefully with install hints

## Portability
- Prefer POSIX-compatible constructs for shell scripts
- Avoid hardcoded paths; use variables or `dirname`/`realpath`
- Handle missing optional dependencies gracefully
- Test on target environments before committing

## Testing
- Non-trivial logic deserves tests
- Prefer integration-style tests for shell scripts
- Unit tests for complex logic in non-system languages
- Include example invocations in comments or help text

## Documentation
- Script header explains: what, why, how to run
- Inline comments for non-obvious logic only
- Keep help text and docs in sync with implementation

## Examples

**Good script header:**
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

**Good Python script pattern:**
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
