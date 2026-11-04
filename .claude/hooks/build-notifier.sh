#!/bin/bash
# Build Claude Code Notifier.app from the installed terminal-notifier. notify.sh
# runs this on first use; rerun it after `brew upgrade terminal-notifier`.
set -euo pipefail
export PATH="/opt/homebrew/bin:$PATH"

cd "$(dirname "${BASH_SOURCE[0]}")"
app="Claude Code Notifier.app"
source="$(dirname "$(readlink -f "$(brew --prefix)/bin/terminal-notifier")")/../terminal-notifier.app"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

cp -R "$source" "$work/$app"
# Claude Code mascot from LobeHub icons (MIT)
cp claude-code.icns "$work/$app/Contents/Resources/Terminal.icns"
plutil -replace CFBundleIdentifier -string fr.julienxx.oss.terminal-notifier.claude "$work/$app/Contents/Info.plist"
plutil -replace CFBundleName -string "Claude Code" "$work/$app/Contents/Info.plist"
plutil -replace CFBundleDisplayName -string "Claude Code" "$work/$app/Contents/Info.plist"
codesign --force --deep --sign - "$work/$app"

rm -rf "$app"
mv "$work/$app" "$app"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app"
echo "Built $app from $(readlink -f "$source")"
