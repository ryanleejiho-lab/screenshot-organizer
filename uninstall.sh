#!/bin/bash
set -euo pipefail

PLIST_DEST="$HOME/Library/LaunchAgents/com.ryanlee.screenshot-organizer.plist"

echo "Removing self-healing LaunchAgent..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
rm -f "$PLIST_DEST"

echo "Reverting screenshot save location to Desktop..."
defaults delete com.apple.screencapture location 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "Done. ~/Desktop/Screenshots and its contents were left untouched."
