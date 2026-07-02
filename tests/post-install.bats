#!/usr/bin/env bats

setup() {
	REPO_ROOT=$(cd "$BATS_TEST_DIRNAME/.." && pwd)
	TEST_HOME="$BATS_TEST_TMPDIR/home"
	TEST_BIN="$BATS_TEST_TMPDIR/bin"
	TEST_APPS="$BATS_TEST_TMPDIR/applications"
	COMMAND_LOG="$BATS_TEST_TMPDIR/commands.log"
	OS_RELEASE="$BATS_TEST_TMPDIR/os-release"

	mkdir -p "$TEST_HOME" "$TEST_BIN" "$TEST_APPS"
	: >"$COMMAND_LOG"

	for command_name in kwriteconfig6 xdg-mime git; do
		cat >"$TEST_BIN/$command_name" <<'EOF'
#!/bin/sh
printf '%s:%s\n' "$(basename "$0")" "$*" >>"$COMMAND_LOG"
EOF
		chmod +x "$TEST_BIN/$command_name"
	done

	cat >"$TEST_BIN/getent" <<'EOF'
#!/bin/sh
[ "$1" = "passwd" ] || exit 1
case "$2" in
plasmalogin) printf 'plasmalogin:x:959:959:Login:/var/lib/plasmalogin:/usr/bin/nologin\n' ;;
*) exit 1 ;;
esac
EOF
	chmod +x "$TEST_BIN/getent"

	cat >"$TEST_BIN/sudo" <<'EOF'
#!/bin/sh
printf 'sudo:%s\n' "$*" >>"$COMMAND_LOG"
EOF
	chmod +x "$TEST_BIN/sudo"

	for desktop_entry in \
		Alacritty.desktop \
		code.desktop \
		firefox.desktop \
		mpv.desktop \
		org.kde.ark.desktop \
		org.kde.dolphin.desktop \
		org.kde.gwenview.desktop \
		org.kde.haruna.desktop \
		vesktop.desktop; do
		: >"$TEST_APPS/$desktop_entry"
	done
}

run_post_install() {
	run env \
		HOME="$TEST_HOME" \
		PATH="$TEST_BIN:/usr/bin:/bin" \
		COMMAND_LOG="$COMMAND_LOG" \
		DOTFILES_APPLICATION_DIRS="$TEST_APPS" \
		DOTFILES_OS_RELEASE_FILE="$OS_RELEASE" \
		DOTFILES_POST_INSTALL_DIRS="$TEST_HOME" \
		DOTFILES_POST_INSTALL_GIT=0 \
		DOTFILES_POST_INSTALL_LOGIN_DISPLAY=0 \
		DOTFILES_POST_INSTALL_PATH=0 \
		DOTFILES_POST_INSTALL_XDG_DIRS=0 \
		SHELL=/bin/zsh \
		XDG_CURRENT_DESKTOP=KDE \
		"$REPO_ROOT/installers/post-install.sh"
}

@test "post-install applies current KDE display layout to Plasma Login" {
	printf 'ID=arch\n' >"$OS_RELEASE"
	mkdir -p "$TEST_HOME/.config"
	printf '{}\n' >"$TEST_HOME/.config/kwinoutputconfig.json"
	: >"$TEST_HOME/.zshrc"

	run env \
		HOME="$TEST_HOME" \
		PATH="$TEST_BIN:/usr/bin:/bin" \
		COMMAND_LOG="$COMMAND_LOG" \
		DOTFILES_APPLICATION_DIRS="$TEST_APPS" \
		DOTFILES_OS_RELEASE_FILE="$OS_RELEASE" \
		DOTFILES_POST_INSTALL_DESKTOP=0 \
		DOTFILES_POST_INSTALL_DIRS="$TEST_HOME" \
		DOTFILES_POST_INSTALL_GIT=0 \
		DOTFILES_POST_INSTALL_PATH=0 \
		DOTFILES_POST_INSTALL_XDG_DIRS=0 \
		SHELL=/bin/zsh \
		XDG_CURRENT_DESKTOP=KDE \
		"$REPO_ROOT/installers/post-install.sh"

	[ "$status" -eq 0 ]
	grep -Fq "sudo:install -D -m 600 -o plasmalogin -g plasmalogin $TEST_HOME/.config/kwinoutputconfig.json /var/lib/plasmalogin/.config/kwinoutputconfig.json" "$COMMAND_LOG"
}

@test "post-install applies curated KDE and XDG defaults" {
	printf 'ID=arch\n' >"$OS_RELEASE"
	: >"$TEST_HOME/.zshrc"

	run_post_install

	[ "$status" -eq 0 ]
	grep -Fq "kwriteconfig6:--file kdeglobals --group General --key TerminalApplication --notify alacritty" "$COMMAND_LOG"
	grep -Fq "kwriteconfig6:--file kglobalshortcutsrc --group services --group Alacritty.desktop --key _launch --notify Ctrl+Alt+T" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default firefox.desktop application/pdf" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default code.desktop text/plain" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default org.kde.gwenview.desktop image/png" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default org.kde.haruna.desktop video/mp4" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default mpv.desktop audio/mpeg" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default org.kde.dolphin.desktop inode/directory" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default org.kde.ark.desktop application/zip" "$COMMAND_LOG"
	grep -Fq "xdg-mime:default vesktop.desktop x-scheme-handler/discord" "$COMMAND_LOG"
}

@test "post-install comments CachyOS zsh source exactly once" {
	printf 'ID=cachyos\nID_LIKE=arch\n' >"$OS_RELEASE"
	cat >"$TEST_HOME/.zshrc" <<'EOF'
source /usr/share/cachyos-zsh-config/cachyos-config.zsh
export KEEP_ME=1
EOF

	run_post_install
	[ "$status" -eq 0 ]
	run_post_install
	[ "$status" -eq 0 ]

	run grep -Fx "#source /usr/share/cachyos-zsh-config/cachyos-config.zsh" "$TEST_HOME/.zshrc"
	[ "$status" -eq 0 ]
	[ "${#lines[@]}" -eq 1 ]
	grep -Fqx "export KEEP_ME=1" "$TEST_HOME/.zshrc"
}

@test "post-install leaves vendor zsh source active outside CachyOS" {
	printf 'ID=arch\n' >"$OS_RELEASE"
	printf '%s\n' 'source /usr/share/cachyos-zsh-config/cachyos-config.zsh' >"$TEST_HOME/.zshrc"

	run_post_install

	[ "$status" -eq 0 ]
	grep -Fqx "source /usr/share/cachyos-zsh-config/cachyos-config.zsh" "$TEST_HOME/.zshrc"
}

@test "post-install skips desktop defaults when KDE tools are unavailable" {
	rm -f "$TEST_BIN/kwriteconfig6" "$TEST_BIN/xdg-mime"
	ln -s "$(command -v dirname)" "$TEST_BIN/dirname"
	printf 'ID=arch\n' >"$OS_RELEASE"
	: >"$TEST_HOME/.zshrc"

	run env \
		HOME="$TEST_HOME" \
		PATH="$TEST_BIN" \
		COMMAND_LOG="$COMMAND_LOG" \
		DOTFILES_APPLICATION_DIRS="$TEST_APPS" \
		DOTFILES_OS_RELEASE_FILE="$OS_RELEASE" \
		DOTFILES_POST_INSTALL_DIRS="$TEST_HOME" \
		DOTFILES_POST_INSTALL_GIT=0 \
		DOTFILES_POST_INSTALL_LOGIN_DISPLAY=0 \
		DOTFILES_POST_INSTALL_PATH=0 \
		DOTFILES_POST_INSTALL_XDG_DIRS=0 \
		SHELL=/bin/zsh \
		XDG_CURRENT_DESKTOP=KDE \
		"$REPO_ROOT/installers/post-install.sh"

	[ "$status" -eq 0 ]
	[ ! -s "$COMMAND_LOG" ]
}
