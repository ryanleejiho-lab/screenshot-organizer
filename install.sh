#!/bin/bash
set -euo pipefail

SCREENSHOTS_DIR="$HOME/Desktop/Screenshots"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_SRC="$SCRIPT_DIR/com.ryanlee.screenshot-organizer.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.ryanlee.screenshot-organizer.plist"

echo "Creating $SCREENSHOTS_DIR..."
mkdir -p "$SCREENSHOTS_DIR"

echo "Sweeping existing screenshots/recordings from Desktop..."
find "$HOME/Desktop" -maxdepth 1 \( -name "Screenshot *.png" -o -name "Screen Recording *.mov" \) -exec mv -n {} "$SCREENSHOTS_DIR" \;

echo "Redirecting screenshot save location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

echo "Installing self-healing LaunchAgent..."
mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DEST"
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo "Done. Screenshots and recordings will now save to $SCREENSHOTS_DIR"
