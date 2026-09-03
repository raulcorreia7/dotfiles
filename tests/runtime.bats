#!/usr/bin/env bats

setup() {
	REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
}

@test "rdf help returns usage text" {
	run bash -c 'DOTFILES_DIR="$1"; export DOTFILES_DIR; . "$1/config/runtime.sh"; rdf help' -- "$REPO_ROOT"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Usage: rdf <command>"* ]]
	[[ "$output" == *"sync [--abort]"* ]]
	[[ "$output" == *"health [scope]"* ]]
}

@test "rdf sync pulls and applies dotfiles setup" {
	fake_repo="$BATS_TEST_TMPDIR/dotfiles"
	fake_bin="$BATS_TEST_TMPDIR/bin"
	mkdir -p "$fake_repo/.git" "$fake_bin"

	mkdir -p "$fake_repo/install"
	cat >"$fake_repo/install/link.sh" <<'EOF'
#!/bin/sh
printf 'link:%s\n' "$*"
EOF
	cat >"$fake_repo/init.sh" <<'EOF'
#!/bin/sh
:
EOF
	chmod +x "$fake_repo/init.sh"

	cat >"$fake_bin/git" <<'EOF'
#!/bin/sh
printf 'git:%s\n' "$*"
EOF
	chmod +x "$fake_bin/git"

	run bash -c 'PATH="$1:/usr/bin:/bin"; DOTFILES_DIR="$2"; export PATH DOTFILES_DIR; . "$3/config/runtime.sh"; rdf sync' -- "$fake_bin" "$fake_repo" "$REPO_ROOT"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Syncing..."* ]]
	[[ "$output" == *"Refreshing dotfiles..."* ]]
	[[ "$output" == *"Reloaded"* ]]
}

@test "rdf health tools detects exa fallback in zsh" {
	command -v zsh >/dev/null 2>&1 || skip "zsh not installed"

	fake_bin="$BATS_TEST_TMPDIR/fake-bin"
	mkdir -p "$fake_bin"

	for tool in fzf git rg fd bat exa stow; do
		printf '#!/bin/sh\nexit 0\n' >"$fake_bin/$tool"
		chmod +x "$fake_bin/$tool"
	done

	run zsh -c 'PATH="$1"; export PATH; . "$2/config/runtime.sh"; rdf health tools' -- "$fake_bin" "$REPO_ROOT"
	[ "$status" -eq 0 ]
	[[ "$output" == *"eza:"*"ok (exa)"* ]]
}

@test "mise plugin adds shims path when sourced" {
	fake_data_home="$BATS_TEST_TMPDIR/mise-data"
	fake_shims_dir="$fake_data_home/mise/shims"
	mkdir -p "$fake_shims_dir"

	for tool in node npm pnpm; do
		printf '#!/bin/sh\nexit 0\n' >"$fake_shims_dir/$tool"
		chmod +x "$fake_shims_dir/$tool"
	done

	run bash -c 'DOTFILES_DIR="$1"; XDG_DATA_HOME="$2"; PATH="/usr/bin:/bin"; export DOTFILES_DIR XDG_DATA_HOME PATH; . "$1/config/runtime.sh"; . "$1/config/plugins/mise/init.sh"; command -v node; command -v npm; command -v pnpm' -- "$REPO_ROOT" "$fake_data_home"
	[ "$status" -eq 0 ]
	[[ "$output" == *"$fake_shims_dir/node"* ]]
	[[ "$output" == *"$fake_shims_dir/npm"* ]]
	[[ "$output" == *"$fake_shims_dir/pnpm"* ]]
}
