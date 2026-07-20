# Screenshot Organizer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redirect all macOS screenshots/recordings to a dedicated `~/Screenshots` folder that's safe to mass-delete anytime, with a self-healing LaunchAgent that recreates the folder if it's ever removed.

**Architecture:** A pair of shell scripts (`install.sh` / `uninstall.sh`) flip the native `com.apple.screencapture location` default and sweep existing Desktop clutter into the new folder. A `launchd` user agent (plist) recreates the folder on login and hourly, so deleting the folder never breaks the next screenshot.

**Tech Stack:** Bash, macOS `defaults`/`launchctl`, `launchd` plist.

---

## File Structure

- `install.sh` — creates `~/Screenshots`, sweeps existing Desktop screenshots/recordings into it, redirects the screencapture default, installs + loads the LaunchAgent.
- `uninstall.sh` — reverts the screencapture default to Desktop, unloads and removes the LaunchAgent. Leaves `~/Screenshots` and its contents untouched.
- `com.ryanlee.screenshot-organizer.plist` — LaunchAgent definition, copied to `~/Library/LaunchAgents/` by `install.sh`.
- `README.md` — what this does, how to install/uninstall.

---

### Task 1: Repo skeleton and README

**Files:**
- Create: `README.md`

- [ ] **Step 1: Write the README**

```markdown
# screenshot-organizer

Redirects macOS screenshots and screen recordings (⌘⇧3/4/5) straight to
`~/Screenshots` instead of the Desktop. The folder is safe to select-all and
delete anytime — a self-healing LaunchAgent recreates it automatically, so
the next screenshot never fails.

## Install

\`\`\`bash
./install.sh
\`\`\`

This will:
- Create `~/Screenshots`
- Move any existing screenshots/recordings already on your Desktop into it
- Redirect future screenshots/recordings there
- Install a LaunchAgent that recreates `~/Screenshots` on login and hourly

## Uninstall

\`\`\`bash
./uninstall.sh
\`\`\`

Reverts screenshots/recordings to save to the Desktop again and removes the
LaunchAgent. `~/Screenshots` and anything in it are left alone.
```

- [ ] **Step 2: Commit**

```bash
cd ~/Developer/screenshot-organizer
git add README.md
git commit -m "Add README"
```

---

### Task 2: Screenshot location redirect

**Files:**
- Create: `install.sh`

- [ ] **Step 1: Check baseline state (verify the default isn't already set)**

Run: `defaults read com.apple.screencapture location`
Expected: `The domain/default pair of (com.apple.screencapture, location) does not exist` (or it prints some other path — either way, note the current value so we know the redirect actually changes something)

- [ ] **Step 2: Create `install.sh` with the folder + redirect logic**

```bash
#!/bin/bash
set -euo pipefail

SCREENSHOTS_DIR="$HOME/Screenshots"

echo "Creating $SCREENSHOTS_DIR..."
mkdir -p "$SCREENSHOTS_DIR"

echo "Redirecting screenshot save location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

echo "Done."
```

- [ ] **Step 3: Make it executable and run it**

Run:
```bash
chmod +x install.sh
./install.sh
```
Expected output: `Creating /Users/ryanlee/Screenshots...` then `Redirecting screenshot save location to /Users/ryanlee/Screenshots...` then `Done.`

- [ ] **Step 4: Verify the redirect took effect**

Run: `defaults read com.apple.screencapture location`
Expected: `/Users/ryanlee/Screenshots`

Run: `ls -ld ~/Screenshots`
Expected: a directory listing showing `~/Screenshots` exists

- [ ] **Step 5: Commit**

```bash
git add install.sh
git commit -m "Add screenshot location redirect"
```

---

### Task 3: One-time sweep of existing Desktop screenshots/recordings

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Check baseline (existing stray screenshots on Desktop)**

Run: `find "$HOME/Desktop" -maxdepth 1 \( -name "Screenshot *.png" -o -name "Screen Recording *.mov" \) | wc -l`
Expected: a number greater than 0 (there are currently loose screenshots/recordings on the Desktop from before this tool existed)

- [ ] **Step 2: Add the sweep step to `install.sh`, between folder creation and the redirect**

```bash
#!/bin/bash
set -euo pipefail

SCREENSHOTS_DIR="$HOME/Screenshots"

echo "Creating $SCREENSHOTS_DIR..."
mkdir -p "$SCREENSHOTS_DIR"

echo "Sweeping existing screenshots/recordings from Desktop..."
find "$HOME/Desktop" -maxdepth 1 \( -name "Screenshot *.png" -o -name "Screen Recording *.mov" \) -exec mv {} "$SCREENSHOTS_DIR" \;

echo "Redirecting screenshot save location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

echo "Done."
```

- [ ] **Step 3: Run it and verify the sweep**

Run: `./install.sh`

Run: `find "$HOME/Desktop" -maxdepth 1 \( -name "Screenshot *.png" -o -name "Screen Recording *.mov" \) | wc -l`
Expected: `0` (nothing matching left on the Desktop)

Run: `ls ~/Screenshots | wc -l`
Expected: a number greater than 0 (matches the count from Task 3 Step 1, plus/minus anything new)

- [ ] **Step 4: Commit**

```bash
git add install.sh
git commit -m "Sweep existing Desktop screenshots into ~/Screenshots on install"
```

---

### Task 4: Self-healing LaunchAgent

**Files:**
- Create: `com.ryanlee.screenshot-organizer.plist`
- Modify: `install.sh`

- [ ] **Step 1: Create the plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.ryanlee.screenshot-organizer</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/mkdir</string>
        <string>-p</string>
        <string>/Users/ryanlee/Screenshots</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>3600</integer>
</dict>
</plist>
```

- [ ] **Step 2: Add LaunchAgent install logic to `install.sh`**

```bash
#!/bin/bash
set -euo pipefail

SCREENSHOTS_DIR="$HOME/Screenshots"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_SRC="$SCRIPT_DIR/com.ryanlee.screenshot-organizer.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/com.ryanlee.screenshot-organizer.plist"

echo "Creating $SCREENSHOTS_DIR..."
mkdir -p "$SCREENSHOTS_DIR"

echo "Sweeping existing screenshots/recordings from Desktop..."
find "$HOME/Desktop" -maxdepth 1 \( -name "Screenshot *.png" -o -name "Screen Recording *.mov" \) -exec mv {} "$SCREENSHOTS_DIR" \;

echo "Redirecting screenshot save location to $SCREENSHOTS_DIR..."
defaults write com.apple.screencapture location "$SCREENSHOTS_DIR"
killall SystemUIServer 2>/dev/null || true

echo "Installing self-healing LaunchAgent..."
mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DEST"
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo "Done. Screenshots and recordings will now save to $SCREENSHOTS_DIR"
```

- [ ] **Step 3: Run it and verify the LaunchAgent is loaded**

Run: `./install.sh`

Run: `launchctl list | grep com.ryanlee.screenshot-organizer`
Expected: a line showing the label `com.ryanlee.screenshot-organizer` (PID/status columns will vary)

- [ ] **Step 4: Verify self-healing — delete the folder and confirm it comes back**

Run:
```bash
rm -rf ~/Screenshots
launchctl kickstart -k "gui/$(id -u)/com.ryanlee.screenshot-organizer"
sleep 1
ls -ld ~/Screenshots
```
Expected: the final `ls -ld` shows `~/Screenshots` exists again

- [ ] **Step 5: Commit**

```bash
git add com.ryanlee.screenshot-organizer.plist install.sh
git commit -m "Add self-healing LaunchAgent for ~/Screenshots"
```

---

### Task 5: Uninstall script

**Files:**
- Create: `uninstall.sh`

- [ ] **Step 1: Write `uninstall.sh`**

```bash
#!/bin/bash
set -euo pipefail

PLIST_DEST="$HOME/Library/LaunchAgents/com.ryanlee.screenshot-organizer.plist"

echo "Removing self-healing LaunchAgent..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
rm -f "$PLIST_DEST"

echo "Reverting screenshot save location to Desktop..."
defaults delete com.apple.screencapture location 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "Done. ~/Screenshots and its contents were left untouched."
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x uninstall.sh`

- [ ] **Step 3: Verify it reverts cleanly (dry run against current install)**

Run: `./uninstall.sh`

Run: `defaults read com.apple.screencapture location`
Expected: `The domain/default pair of (com.apple.screencapture, location) does not exist` (back to macOS's default, which is the Desktop)

Run: `launchctl list | grep com.ryanlee.screenshot-organizer`
Expected: no output (no matching line — agent is gone)

Run: `ls -ld ~/Screenshots`
Expected: the folder still exists (uninstall does not delete it or its contents)

- [ ] **Step 4: Re-run install.sh to restore the working state**

Run: `./install.sh`

Run: `defaults read com.apple.screencapture location`
Expected: `/Users/ryanlee/Screenshots`

- [ ] **Step 5: Commit**

```bash
git add uninstall.sh
git commit -m "Add uninstall script"
```

---

### Task 6: Push to GitHub

**Files:** none (repo-level operation)

- [ ] **Step 1: Confirm the repo is in the expected state**

Run: `cd ~/Developer/screenshot-organizer && git status && git log --oneline`
Expected: clean working tree, commit history showing the README, install.sh, plist, and uninstall.sh commits (plus the earlier design-spec commit)

- [ ] **Step 2: Create the GitHub repo**

Run: `gh repo create screenshot-organizer --private --source=. --remote=origin`
Expected: output confirming repo creation, e.g. `✓ Created repository ryanleejiho-lab/screenshot-organizer on GitHub`

- [ ] **Step 3: Push**

Run: `git push -u origin main`
Expected: output showing the branch pushed and set to track `origin/main`

- [ ] **Step 4: Verify on GitHub**

Run: `gh repo view ryanleejiho-lab/screenshot-organizer --web=false`
Expected: repo metadata printed, confirming it exists under the account

---

## Notes for the implementer

- Task 2 Step 3 and Task 3 Step 3 and Task 4 Step 3 all run the real `install.sh` against Ryan's actual machine — this is intentional (he asked for this tool to be live on his Mac), not a test-environment run. Each re-run is idempotent (safe to run multiple times).
- Task 4 Step 4 temporarily deletes the real `~/Screenshots` folder to prove the self-heal works, then immediately recreates it — don't skip the recreation check.
- Repo visibility is set to `--private` in Task 6 Step 2 since this is a personal utility tied to Ryan's local file paths; switch to `--public` only if he asks.
