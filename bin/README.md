# bin/

User scripts that get symlinked to `~/.local/bin/`.

Add your custom executable scripts here. They will be available in your PATH
after running `installers/link.sh`.

## Usage

1. Add an executable script to this directory
2. Run `installers/link.sh` (or `./install`)
3. Script is now available as a command

## Example

```bash
#!/bin/sh
# hello: simple greeting script
echo "Hello from dotfiles!"
```
