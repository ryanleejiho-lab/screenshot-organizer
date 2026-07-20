# Screenshot Organizer — Design

## Problem

Screenshots and screen recordings taken via macOS's built-in capture tool
(⌘⇧3 / ⌘⇧4 / ⌘⇧5) save to the Desktop by default, cluttering it. Ryan deletes
these eventually anyway, so auto-deleting them is unnecessary and risky
(might delete something still needed). What's wanted is a dedicated,
disposable holding folder that captures land in automatically, which can be
mass-emptied at any time without breaking future captures.

## Approach

Redirect macOS's screenshot save location (`com.apple.screencapture
location`) to a dedicated folder, `~/Screenshots`. This is the native OS
setting Apple provides for this exact purpose — every future capture writes
there directly, never touching the Desktop. A small self-healing LaunchAgent
recreates the folder if it's ever deleted, so mass-deleting the whole folder
(not just its contents) never breaks the next screenshot.

Rejected alternative: a background watcher that moves new screenshots off
the Desktop after the fact. This adds a persistent process, lets files flash
on the Desktop before being moved, and is more likely to silently break
(similar to the Finder hang encountered earlier this session) than a native
OS setting plus a trivial folder-existence check.

## Components

1. **`~/Screenshots` folder** — single dedicated destination. Safe to
   select-all-delete its contents, or delete the folder entirely, at any
   time.
2. **Screenshot location redirect** — `defaults write com.apple.screencapture
   location ~/Screenshots` followed by `killall SystemUIServer` to apply
   immediately. Covers both screenshots and screen recordings taken through
   the capture toolbar.
3. **Self-healing LaunchAgent** — a `launchd` user agent
   (`com.ryanlee.screenshot-organizer.plist`) that runs `mkdir -p
   ~/Screenshots` at login and once an hour, so the folder always exists
   before the next capture.
4. **One-time sweep** — on install, move any existing screenshot/recording
   files already on the Desktop (matching macOS's default naming pattern,
   e.g. `Screenshot 2026-07-19 at 1.11.32 PM.png`, `Screen Recording
   2026-07-19 at 1.11.09 PM.mov`) into `~/Screenshots`, so setup starts from
   a clean Desktop.
5. **Install / uninstall scripts** — `install.sh` applies the `defaults`
   setting, creates the folder, sweeps existing files, and loads the
   LaunchAgent. `uninstall.sh` reverts the `defaults` setting to macOS's
   default (Desktop) and unloads/removes the LaunchAgent. The `~/Screenshots`
   folder and its contents are left untouched by uninstall.

## Out of scope

- No archiving/organizing by date — this is a disposable holding folder, not
  an archive.
- No deletion of old files — Ryan deletes manually when ready.
- No handling of screenshots from third-party tools (e.g. CleanShot) — only
  macOS's built-in capture path.

## Repo

New repo `screenshot-organizer` under `~/Developer/screenshot-organizer`,
pushed to Ryan's GitHub (`ryanleejiho-lab`).
