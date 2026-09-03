#!/bin/sh
# KDE and XDG desktop defaults applied during post-install configuration.

desktop_entry_exists() {
  desktop_entry="$1"
  application_dirs="${DOTFILES_APPLICATION_DIRS:-$HOME/.local/share/applications:/usr/local/share/applications:/usr/share/applications}"

  old_ifs=$IFS
  IFS=:
  for application_dir in $application_dirs; do
    if [ -f "$application_dir/$desktop_entry" ]; then
      IFS=$old_ifs
      return 0
    fi
  done
  IFS=$old_ifs

  return 1
}

set_mime_default() {
  desktop_entry="$1"
  shift

  desktop_entry_exists "$desktop_entry" || {
    log "desktop entry not found, skipping defaults for $desktop_entry"
    return 0
  }

  for mime_type in "$@"; do
    xdg-mime default "$desktop_entry" "$mime_type" || {
      log "failed to set $mime_type default to $desktop_entry"
      return 1
    }
  done
}

is_kde_desktop() {
  case "${XDG_CURRENT_DESKTOP:-}:${DESKTOP_SESSION:-}" in
  *KDE* | *kde* | *Plasma* | *plasma*) return 0 ;;
  *) return 1 ;;
  esac
}

configure_kde_defaults() {
  command -v kwriteconfig6 >/dev/null 2>&1 || {
    log "kwriteconfig6 not found, skipping KDE defaults"
    return 0
  }

  desktop_entry_exists "Alacritty.desktop" || {
    log "Alacritty.desktop not found, skipping KDE terminal defaults"
    return 0
  }

  kwriteconfig6 --file kdeglobals --group General --key TerminalApplication --notify "alacritty"
  kwriteconfig6 --file kdeglobals --group General --key TerminalService --notify "Alacritty.desktop"
  kwriteconfig6 --file kglobalshortcutsrc --group services --group Alacritty.desktop --key _launch --notify "Ctrl+Alt+T"

  if desktop_entry_exists "com.mitchellh.ghostty.desktop"; then
    kwriteconfig6 --file kglobalshortcutsrc --group services --group com.mitchellh.ghostty.desktop --key _launch --notify ""
  fi
  if desktop_entry_exists "org.kde.konsole.desktop"; then
    kwriteconfig6 --file kglobalshortcutsrc --group services --group org.kde.konsole.desktop --key _launch --notify "none"
  fi
}

configure_xdg_defaults() {
  command -v xdg-mime >/dev/null 2>&1 || {
    log "xdg-mime not found, skipping application defaults"
    return 0
  }

  set_mime_default "firefox.desktop" \
    "x-scheme-handler/http" \
    "x-scheme-handler/https" \
    "x-scheme-handler/mailto" \
    "text/html" \
    "application/xhtml+xml" \
    "application/xml" \
    "text/xml" \
    "application/pdf"

  set_mime_default "code.desktop" \
    "text/plain" \
    "application/json" \
    "application/x-shellscript" \
    "text/x-c" \
    "text/x-c++src" \
    "text/x-chdr" \
    "text/x-c++hdr" \
    "text/x-java" \
    "text/x-python" \
    "text/x-script.python" \
    "text/x-lua" \
    "text/x-rust" \
    "text/markdown"

  set_mime_default "org.kde.gwenview.desktop" \
    "image/avif" \
    "image/gif" \
    "image/jpeg" \
    "image/png" \
    "image/svg+xml" \
    "image/webp"

  set_mime_default "org.kde.haruna.desktop" \
    "video/mp4" \
    "video/x-matroska" \
    "video/mpeg" \
    "video/ogg" \
    "video/quicktime" \
    "video/webm"

  set_mime_default "mpv.desktop" \
    "audio/aac" \
    "audio/flac" \
    "audio/mp4" \
    "audio/mpeg" \
    "audio/ogg" \
    "audio/vnd.wave" \
    "audio/webm"

  set_mime_default "org.kde.dolphin.desktop" "inode/directory"

  set_mime_default "org.kde.ark.desktop" \
    "application/gzip" \
    "application/vnd.rar" \
    "application/x-7z-compressed" \
    "application/x-bzip2" \
    "application/x-compressed-tar" \
    "application/x-tar" \
    "application/x-xz" \
    "application/zip"

  if desktop_entry_exists "vesktop.desktop"; then
    set_mime_default "vesktop.desktop" "x-scheme-handler/discord"
  fi
}

configure_desktop_defaults() {
  [ "${DOTFILES_POST_INSTALL_DESKTOP:-1}" = "1" ] || return 0

  is_kde_desktop || {
    log "KDE desktop not detected, skipping desktop defaults"
    return 0
  }

  configure_kde_defaults
  configure_xdg_defaults
}
