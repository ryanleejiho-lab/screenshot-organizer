# screenshot-organizer

Redirects macOS screenshots and screen recordings (⌘⇧3/4/5) straight to
`~/Screenshots` instead of the Desktop. The folder is safe to select-all and
delete anytime — a self-healing LaunchAgent recreates it automatically, so
the next screenshot never fails.

## Install

```bash
./install.sh
```

This will:
- Create `~/Screenshots`
- Move any existing screenshots/recordings already on your Desktop into it
- Redirect future screenshots/recordings there
- Install a LaunchAgent that recreates `~/Screenshots` on login and hourly

## Uninstall

```bash
./uninstall.sh
```

Reverts screenshots/recordings to save to the Desktop again and removes the
LaunchAgent. `~/Screenshots` and anything in it are left alone.

## Note for forks

`com.ryanlee.screenshot-organizer.plist` hardcodes `/Users/ryanlee/Screenshots`
(launchd plists can't expand `$HOME`). If you fork this, edit that path to
match your own username before running `install.sh`.
