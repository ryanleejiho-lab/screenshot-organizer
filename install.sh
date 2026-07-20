#!/bin/bash
set -euo pipefail

SCREENSHOTS_DIR="$HOME/Screenshots"

echo "Creating $SCREENSHOTS_DIR..."
mkdir -p "$SCREENSHOTS_DIR"

echo "Redirecting screenshot save location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

echo "Done."
