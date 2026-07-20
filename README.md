# screenshot-organizer

**macOS only** — this uses `defaults`, `launchd`, and macOS's built-in
screenshot tool, none of which exist on Windows/Linux.

Redirects macOS screenshots and screen recordings (⌘⇧3/4/5) straight to
`~/Screenshots` instead of the Desktop. The folder is safe to select-all and
delete anytime — a self-healing LaunchAgent recreates it automatically, so
the next screenshot never fails.

## Install

1. Clone the repo and enter it:

   ```bash
   git clone https://github.com/ryanleejiho-lab/screenshot-organizer.git
   cd screenshot-organizer
   ```

2. Run the install script:

   ```bash
   ./install.sh
   ```

This will:
- Create `~/Screenshots`
- Move any existing screenshots/recordings already on your Desktop into it
- Redirect future screenshots/recordings there
- Install a LaunchAgent that recreates `~/Screenshots` on login and hourly

No dependencies to install — it's plain bash and macOS's own `defaults`/
`launchctl` commands, both already on your system.

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
