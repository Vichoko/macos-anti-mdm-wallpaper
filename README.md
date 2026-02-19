# macOS Anti-MDM Wallpaper

Automatically restores your preferred wallpaper when MDM software forcefully changes it on macOS.

## Problem

Some Mobile Device Management (MDM) software like ManageEngine forcefully changes your macOS wallpaper to a corporate image. This tool monitors your wallpaper every 60 seconds and automatically restores your preferred wallpaper when it detects MDM interference.

## Compatibility

- macOS 15.3+ (Sequoia)
- Tested with ManageEngine UEMS Agent
- Works with multi-monitor setups

## How It Works

1. **check_and_fix_wallpaper.sh** - Main script that runs every 60 seconds via launchd
2. **current_wallpaper.sh** - Detects current wallpaper using AppleScript
3. **set_wallpaper.sh** - Restores your preferred wallpaper
4. **close_aerial.sh** & **open_aerial.sh** - Restarts Aerial screensaver app (optional)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Vichoko/macos-anti-mdm-wallpaper.git
cd macos-anti-mdm-wallpaper
```

### 2. Configure Your Preferred Wallpaper

Edit `set_wallpaper.sh` and change the wallpaper path to your preferred one:

```bash
# Default:
set picture of d to "/System/Library/Desktop Pictures/Big Sur Coastline.madesktop"

# Change to your preferred wallpaper, for example:
set picture of d to "/System/Library/Desktop Pictures/Sonoma.madesktop"
```

Available wallpapers can be found in `/System/Library/Desktop Pictures/`

### 3. Update Script Paths

Edit `check_and_fix_wallpaper.sh` and update line 81 with your actual path:

```bash
SCRIPT_DIR="/path/to/your/macos-anti-mdm-wallpaper"
```

### 4. Make Scripts Executable

```bash
chmod +x *.sh
```

### 5. Create LaunchAgent

Create `~/Library/LaunchAgents/com.vicente.check_wallpaper.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.vicente.check_wallpaper</string>

  <key>ProgramArguments</key>
  <array>
    <string>/path/to/your/macos-anti-mdm-wallpaper/check_and_fix_wallpaper.sh</string>
  </array>

  <key>StartInterval</key>
  <integer>60</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/check_wallpaper.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/check_wallpaper.err</string>
</dict>
</plist>
```

### 6. Load the LaunchAgent

```bash
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

## Usage

Once installed, the script runs automatically every 60 seconds. Check the logs:

```bash
# View activity log
tail -f /tmp/check_wallpaper.log

# View errors
tail -f /tmp/check_wallpaper.err
```

The log will only show entries when MDM interference is detected and corrected:
```
2026-02-19 09:42:15 - Wallpaper gestionado por ManageEngine detectado, corrigiendo…
```

## Management Commands

```bash
# Check if running
launchctl list | grep com.vicente.check_wallpaper

# Stop the monitor
launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist

# Start the monitor
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

## Customization

### Without Aerial Screensaver

If you don't use Aerial, comment out these lines in `check_and_fix_wallpaper.sh`:

```bash
# "$SCRIPT_DIR/close_aerial.sh"
# "$SCRIPT_DIR/open_aerial.sh"
```

### Different MDM Software

Edit the `TARGET` variable in `check_and_fix_wallpaper.sh` to match your MDM's wallpaper path:

```bash
TARGET="/Library/ManageEngine/UEMS_Agent/configuration/user/wallpaper/Copy of WallpaperLightModeESPFV.png"
```

### Change Check Interval

Modify `StartInterval` in the plist file (value in seconds):

```xml
<key>StartInterval</key>
<integer>60</integer>  <!-- Check every 60 seconds -->
```

## Troubleshooting

### Script runs but wallpaper doesn't change

1. Check that the wallpaper path in `set_wallpaper.sh` is correct
2. Verify the file exists: `ls -la "/System/Library/Desktop Pictures/Your Wallpaper.madesktop"`
3. For macOS 15.3+, use the `.madesktop` path directly, not the internal `.heic` file

### Permissions Issues

Ensure Terminal or the parent app has:
- Full Disk Access
- Automation permissions for System Events

Go to: System Settings > Privacy & Security > Automation

## License

MIT
