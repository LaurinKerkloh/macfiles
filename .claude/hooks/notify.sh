#!/bin/bash
# Claude Code Notification hook: macOS notification that jumps back to the
# tmux pane Claude is running in when clicked.
#
# Claude Code Notifier.app is a copy of terminal-notifier with the Claude Code
# icon (macOS takes a notification's icon from the sending app). It's built on
# first use by build-notifier.sh and needs notifications allowed once in
# System Settings → Notifications.

hooks="$(dirname "${BASH_SOURCE[0]}")"
notifier="$hooks/Claude Code Notifier.app/Contents/MacOS/terminal-notifier"
[ -x "$notifier" ] || "$hooks/build-notifier.sh" >/dev/null 2>&1 || exit 0

message=$(/opt/homebrew/bin/jq -r '.message // "Claude needs your attention"')
title="Claude Code"
args=(-message "$message" -sound Glass)

if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
  tmux=/opt/homebrew/bin/tmux
  socket=${TMUX%%,*}
  session=$("$tmux" -S "$socket" display -p -t "$TMUX_PANE" '#{session_name}')
  title="$session · Claude Code"
  args+=(-group "claude-$TMUX_PANE")
  args+=(-execute "open -b com.mitchellh.ghostty; $tmux -S '$socket' switch-client -t '$TMUX_PANE' \\; select-window -t '$TMUX_PANE' \\; select-pane -t '$TMUX_PANE'")
else
  args+=(-activate com.mitchellh.ghostty)
fi

"$notifier" -title "$title" "${args[@]}" >/dev/null
