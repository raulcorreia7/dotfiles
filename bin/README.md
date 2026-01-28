# bin/

User scripts that get symlinked to `~/.local/bin/`.

Add your custom executable scripts here. They will be available in your PATH
after running `lib/install/link.sh`.

## Usage

1. Add an executable script to this directory
2. Run `lib/install/link.sh` (or `./install`)
3. Script is now available as a command

## Example

```bash
#!/bin/sh
# my-script: description of what it does
echo "Your script here!"
```
