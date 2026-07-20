# screenshot-organizer

**macOS only** — this uses `defaults`, `launchd`, and macOS's built-in
screenshot tool, none of which exist on Windows/Linux.

Redirects macOS screenshots and screen recordings (⌘⇧3/4/5) into a
`Screenshots` folder that lives right on your Desktop, instead of littering
the Desktop itself with individual files. The folder is safe to select-all
and delete anytime — a self-healing LaunchAgent watches for the folder
disappearing and recreates it within moments, so the next screenshot never
falls back to landing loose on the Desktop.

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
- Create `~/Desktop/Screenshots`
- Move any existing screenshots/recordings already on your Desktop into it
- Redirect future screenshots/recordings there
- Install a LaunchAgent that recreates `~/Desktop/Screenshots` on login and hourly

No dependencies to install — it's plain bash and macOS's own `defaults`/
`launchctl` commands, both already on your system.

## Uninstall

```bash
./uninstall.sh
```

Reverts screenshots/recordings to save directly to the Desktop again and
removes the LaunchAgent. `~/Desktop/Screenshots` and anything in it are left
alone.

## Note for forks

`com.ryanlee.screenshot-organizer.plist` hardcodes
`/Users/ryanlee/Desktop/Screenshots` (launchd plists can't expand `$HOME`).
If you fork this, edit that path to match your own username before running
`install.sh`.
