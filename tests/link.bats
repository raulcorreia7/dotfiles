#!/usr/bin/env bats

setup() {
	REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
	TEST_HOME="$BATS_TEST_TMPDIR/home"
	TEST_CONFIG="$TEST_HOME/.config"
	TEST_CODEX="$TEST_HOME/.codex"
	mkdir -p "$TEST_HOME"
}

run_link() {
	run env \
		HOME="$TEST_HOME" \
		XDG_CONFIG_HOME="$TEST_CONFIG" \
		CODEX_HOME="$TEST_CODEX" \
		DOTFILES_DIR="$REPO_ROOT" \
		DOTFILES_INTERACTIVE=0 \
		"$REPO_ROOT/installers/link.sh"
}

@test "link creates documented agent configuration paths" {
	run_link

	[ "$status" -eq 0 ]
	[ "$(readlink "$TEST_HOME/.agents")" = "$TEST_CONFIG/agents" ]
	[ "$(readlink "$TEST_CODEX/AGENTS.md")" = "$TEST_CONFIG/agents/AGENTS.md" ]
	[ "$(readlink "$TEST_CODEX/config.toml")" = "$TEST_CONFIG/codex/config.toml" ]
	[ -f "$TEST_HOME/.agents/skills/README.md" ]
	[ -f "$TEST_CONFIG/opencode/commands/commit.md" ]
	[ -f "$TEST_CONFIG/opencode/rules/coding.md" ]
}

@test "link is idempotent" {
	run_link
	[ "$status" -eq 0 ]

	run_link
	[ "$status" -eq 0 ]
	[ "$(readlink "$TEST_HOME/.agents")" = "$TEST_CONFIG/agents" ]
}

@test "link backs up an existing agents directory" {
	mkdir -p "$TEST_HOME/.agents"
	printf 'keep\n' >"$TEST_HOME/.agents/local.txt"

	run_link

	[ "$status" -eq 0 ]
	[ -L "$TEST_HOME/.agents" ]
	[ "$(readlink "$TEST_HOME/.agents")" = "$TEST_CONFIG/agents" ]
	[ "$(cat "$TEST_HOME/.agents.bak/local.txt")" = "keep" ]
}

@test "link uses the next available agents backup suffix" {
	mkdir -p "$TEST_HOME/.agents" "$TEST_HOME/.agents.bak"
	printf 'current\n' >"$TEST_HOME/.agents/current.txt"
	printf 'older\n' >"$TEST_HOME/.agents.bak/older.txt"

	run_link

	[ "$status" -eq 0 ]
	[ "$(cat "$TEST_HOME/.agents.bak/older.txt")" = "older" ]
	[ "$(cat "$TEST_HOME/.agents.bak.1/current.txt")" = "current" ]
}

@test "uninstall restores the latest agents backup" {
	mkdir -p "$TEST_HOME/.agents" "$TEST_HOME/.agents.bak"
	printf 'latest\n' >"$TEST_HOME/.agents/latest.txt"
	printf 'older\n' >"$TEST_HOME/.agents.bak/older.txt"

	run_link
	[ "$status" -eq 0 ]
	[ -d "$TEST_HOME/.agents.bak.1" ]

	run env \
		HOME="$TEST_HOME" \
		XDG_CONFIG_HOME="$TEST_CONFIG" \
		DOTFILES_DIR="$REPO_ROOT" \
		DOTFILES_INTERACTIVE=0 \
		"$REPO_ROOT/uninstall" --all

	[ "$status" -eq 0 ]
	[ ! -L "$TEST_HOME/.agents" ]
	[ "$(cat "$TEST_HOME/.agents/latest.txt")" = "latest" ]
	[ "$(cat "$TEST_HOME/.agents.bak/older.txt")" = "older" ]
}

@test "link reports an unreplaceable agents path without deleting it" {
	fake_bin="$BATS_TEST_TMPDIR/bin"
	real_mv=$(command -v mv)
	mkdir -p "$fake_bin" "$TEST_HOME/.agents"
	printf 'keep\n' >"$TEST_HOME/.agents/local.txt"

	cat >"$fake_bin/mv" <<EOF
#!/bin/sh
if [ "\$1" = "$TEST_HOME/.agents" ]; then
  exit 1
fi
exec "$real_mv" "\$@"
EOF
	chmod +x "$fake_bin/mv"

	run env \
		HOME="$TEST_HOME" \
		XDG_CONFIG_HOME="$TEST_CONFIG" \
		CODEX_HOME="$TEST_CODEX" \
		DOTFILES_DIR="$REPO_ROOT" \
		DOTFILES_INTERACTIVE=0 \
		PATH="$fake_bin:$PATH" \
		"$REPO_ROOT/installers/link.sh"

	[ "$status" -ne 0 ]
	[[ "$output" == *"Cannot move $TEST_HOME/.agents"* ]]
	[ "$(cat "$TEST_HOME/.agents/local.txt")" = "keep" ]
}

@test "health reports the direct agent links" {
	run_link
	[ "$status" -eq 0 ]

	run env \
		HOME="$TEST_HOME" \
		XDG_CONFIG_HOME="$TEST_CONFIG" \
		CODEX_HOME="$TEST_CODEX" \
		DOTFILES_DIR="$REPO_ROOT" \
		bash -c '. "$DOTFILES_DIR/config/runtime.sh"; dot_health_links'

	[ "$status" -eq 0 ]
	[[ "$output" == *".agents:"*"ok"* ]]
	[[ "$output" == *"codex-agents:"*"ok"* ]]
	[[ "$output" == *"codex-config:"*"ok"* ]]
}
