# macOS Anti-MDM Wallpaper

🛡️ Automatically restores your preferred wallpaper when MDM software forcefully changes it on macOS.

## 📋 Table of Contents

- [The Problem](#the-problem)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [Usage](#usage)
- [Management](#management)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)

## The Problem

Some Mobile Device Management (MDM) software like ManageEngine forcefully changes your macOS wallpaper to a corporate image. This tool monitors your wallpaper every 60 seconds and automatically restores your preferred wallpaper when it detects MDM interference.

**Compatibility:**
- ✅ macOS 15.3+ (Sequoia) - may work on earlier versions
- ✅ Multi-monitor setups
- ✅ Tested with ManageEngine UEMS Agent
- ✅ Works with `.madesktop` and `.heic` wallpapers

## 🚀 Quick Start

Three simple commands to protect your wallpaper:

```bash
git clone https://github.com/Vichoko/macos-anti-mdm-wallpaper.git
cd macos-anti-mdm-wallpaper
./install.sh
```

That's it! The script will now run automatically in the background.

## How It Works

The system consists of 5 scripts working together:

| Script | Purpose |
|--------|---------|
| **check_and_fix_wallpaper.sh** | Main monitoring script (runs every 60s via LaunchAgent) |
| **current_wallpaper.sh** | Detects current wallpaper using AppleScript |
| **set_wallpaper.sh** | Restores your preferred wallpaper |
| **close_aerial.sh** | Closes Aerial screensaver (optional) |
| **open_aerial.sh** | Reopens Aerial after wallpaper change (optional) |
| **install.sh** | Automated installer |
| **uninstall.sh** | Clean removal script |

**Flow:**
1. LaunchAgent executes `check_and_fix_wallpaper.sh` every 60 seconds
2. Script checks if current wallpaper matches MDM's forced wallpaper
3. If match detected → restore preferred wallpaper → restart Aerial (optional)
4. Log the incident with timestamp

## Installation

### Prerequisites

- macOS with Terminal access
- Git (usually pre-installed)
- No admin/sudo required for user LaunchAgents

### Option 1: Automated Installation (Recommended)

**Step 1:** Clone the repository

```bash
git clone https://github.com/Vichoko/macos-anti-mdm-wallpaper.git
cd macos-anti-mdm-wallpaper
```

**Step 2:** (Optional) Choose your wallpaper

The default wallpaper is **Valley.madesktop**. To change it:

```bash
nano set_wallpaper.sh
# Edit line 6 with your preferred wallpaper
```

<details>
<summary>📸 See available wallpapers</summary>

Browse system wallpapers:
```bash
ls -1 "/System/Library/Desktop Pictures/" | grep -E "\.(heic|madesktop)$"
```

Popular choices:
- `Sonoma.heic` - macOS Sonoma default
- `Ventura Graphic.madesktop` - macOS Ventura
- `The Cliffs.madesktop` - Natural scenery
- `Solar Gradients.madesktop` - Colorful abstract
- `Big Sur Coastline.madesktop` - Classic coastal view

</details>

**Step 3:** Run the installer

```bash
./install.sh
```

**Expected output:**
```
🚀 Instalador anti-MDM wallpaper
================================

📁 Directorio de instalación: /Users/your.user/path/to/macos-anti-mdm-wallpaper
👤 Usuario: your.user

🔍 Verificando scripts...
  ✓ check_and_fix_wallpaper.sh
  ✓ current_wallpaper.sh
  ✓ set_wallpaper.sh
  ✓ close_aerial.sh
  ✓ open_aerial.sh

🔧 Configurando permisos de ejecución...
📝 Actualizando rutas...
🚀 Cargando LaunchAgent...
✅ Verificando instalación...
✓ LaunchAgent cargado exitosamente

🎉 Instalación completada exitosamente
```

**Done!** The monitoring service is now active.

### Option 2: Manual Installation

<details>
<summary>Click to expand manual installation steps</summary>

**Step 1:** Clone and navigate

```bash
git clone https://github.com/Vichoko/macos-anti-mdm-wallpaper.git
cd macos-anti-mdm-wallpaper
```

### 2. Configure Your Preferred Wallpaper

Edit `set_wallpaper.sh` and change the wallpaper path:

```bash
nano set_wallpaper.sh
```

Change line 6:
```bash
# Default:
set picture of d to "/System/Library/Desktop Pictures/Valley.madesktop"

# Change to your preferred wallpaper, for example:
set picture of d to "/System/Library/Desktop Pictures/Sonoma.heic"
```

**Step 2:** Update script directory path

Edit `check_and_fix_wallpaper.sh`:

```bash
nano check_and_fix_wallpaper.sh
```

Update line 81 with your actual absolute path:
```bash
SCRIPT_DIR="/Users/your.user/path/to/macos-anti-mdm-wallpaper"
```

**Step 3:** Make scripts executable

```bash
chmod +x *.sh
```

**Step 4:** Create LaunchAgent plist

```bash
nano ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

Paste this content (replace the path):

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
    <string>/Users/your.user/path/to/macos-anti-mdm-wallpaper/check_and_fix_wallpaper.sh</string>
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

**Step 5:** Load the LaunchAgent

```bash
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

**Step 6:** Verify it's running

```bash
launchctl list | grep check_wallpaper
# Should show: -    0    com.vicente.check_wallpaper
```

</details>

### Updating from Previous Installation

If you already have an older version installed:

```bash
cd macos-anti-mdm-wallpaper
git pull
./install.sh  # Will detect and update existing installation
```

## Usage

### Automatic Monitoring

Once installed, the script runs silently in the background every 60 seconds. You don't need to do anything!

### Checking the Logs

The script only logs when MDM interference is detected:

```bash
# View recent activity
tail -20 /tmp/check_wallpaper.log

# Monitor in real-time
tail -f /tmp/check_wallpaper.log

# Check for errors
tail -f /tmp/check_wallpaper.err
```

**Example log entry when MDM is detected:**
```
2026-02-26 14:23:45 - Wallpaper gestionado por ManageEngine detectado, corrigiendo…
```

### Testing It Works

To verify the system is working:

1. **Check service status:**
   ```bash
   launchctl list | grep check_wallpaper
   # Should show: -    0    com.vicente.check_wallpaper
   ```

2. **Test wallpaper detection:**
   ```bash
   cd macos-anti-mdm-wallpaper
   ./current_wallpaper.sh
   # Shows your current wallpaper path(s)
   ```

3. **Test wallpaper setting:**
   ```bash
   ./set_wallpaper.sh
   # Immediately applies your preferred wallpaper
   ```

## Management

### Common Commands

```bash
# Check if service is running
launchctl list | grep check_wallpaper

# View service details
launchctl list com.vicente.check_wallpaper

# Repair or reinstall (safe to run multiple times)
./install.sh

# Completely remove the service
./uninstall.sh

# View recent activity
tail -20 /tmp/check_wallpaper.log

# Clear logs
rm /tmp/check_wallpaper.log /tmp/check_wallpaper.err
```

### Manual Service Control

```bash
# Stop the monitoring service
launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist

# Start the monitoring service
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist

# Restart the service
launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

### Uninstallation

Run the uninstall script:

```bash
cd macos-anti-mdm-wallpaper
./uninstall.sh
```

This will:
1. Stop the LaunchAgent
2. Remove the plist file
3. Optionally delete logs

**Note:** The scripts remain in place for future use.

## Customization

### Change Wallpaper

Edit `set_wallpaper.sh`:

```bash
nano set_wallpaper.sh
```

Change line 6 to your preferred wallpaper:
```bash
set picture of d to "/System/Library/Desktop Pictures/YourChoice.madesktop"
```

Then reload the service:
```bash
./install.sh  # Automatically updates configuration
```

### Change Monitor Frequency

The default check interval is 60 seconds. To change it:

**If using automated install:**
Edit the `install.sh` script, find this line and change the value:
```bash
<key>StartInterval</key>
<integer>60</integer>  <!-- Change this number (seconds) -->
```

**If manually installed:**
Edit `~/Library/LaunchAgents/com.vicente.check_wallpaper.plist` and reload:
```bash
nano ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
# Change StartInterval value
launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
```

### Different MDM Software

If your MDM uses a different wallpaper path:

1. Find your MDM's wallpaper path:
   ```bash
   ./current_wallpaper.sh
   # When MDM forces the wallpaper, note the path
   ```

2. Edit `check_and_fix_wallpaper.sh`:
   ```bash
   nano check_and_fix_wallpaper.sh
   ```

3. Update line 82:
   ```bash
   TARGET="/path/to/your/mdm/wallpaper/file.png"
   ```

4. Reload:
   ```bash
   ./install.sh
   ```

### Without Aerial Screensaver

If you don't use [Aerial](https://aerialscreensaver.github.io/), disable the restart commands:

Edit `check_and_fix_wallpaper.sh` and comment out lines 92-93:

```bash
nano check_and_fix_wallpaper.sh
```

```bash
if [[ "$current_wallpaper" == *"$TARGET"* ]]; then
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$timestamp - Wallpaper gestionado por ManageEngine detectado, corrigiendo…"
  "$SCRIPT_DIR/set_wallpaper.sh"
  # "$SCRIPT_DIR/close_aerial.sh"    # Commented out
  # "$SCRIPT_DIR/open_aerial.sh"     # Commented out
fi
```

### Multi-User Setup

Each user needs their own installation:

```bash
# As user 1
cd ~/Downloads
git clone https://github.com/Vichoko/macos-anti-mdm-wallpaper.git
cd macos-anti-mdm-wallpaper
./install.sh

# As user 2 (repeat same steps)
```

Each user's LaunchAgent runs independently.

## Troubleshooting

### Service Not Running

**Problem:** `launchctl list | grep check_wallpaper` returns nothing

**Solutions:**
```bash
# Verify plist exists
ls -la ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist

# If missing, reinstall
cd macos-anti-mdm-wallpaper
./install.sh

# Check for errors in system log
log show --predicate 'process == "launchd"' --last 5m | grep check_wallpaper
```

### Wallpaper Not Changing

**Problem:** Script runs but wallpaper doesn't restore

**Check 1:** Verify wallpaper path exists
```bash
# Test the exact path in set_wallpaper.sh
ls -la "/System/Library/Desktop Pictures/Valley.madesktop"

# If error, choose a different wallpaper
ls "/System/Library/Desktop Pictures/" | grep -E "\.(heic|madesktop)$"
```

**Check 2:** Test manual execution
```bash
cd macos-anti-mdm-wallpaper
./set_wallpaper.sh
# Wallpaper should change immediately
```

**Check 3:** Verify MDM path detection
```bash
./current_wallpaper.sh
# Compare output with TARGET in check_and_fix_wallpaper.sh
```

**Check 4:** macOS version compatibility
- For macOS 15.3+: Use `.madesktop` bundles
- For older macOS: Use `.heic` or `.jpg` files directly

### Permissions Issues

**Problem:** Script fails with permissions error

**Solutions:**

1. **Grant Terminal Full Disk Access:**
   - System Settings → Privacy & Security → Full Disk Access
   - Add Terminal.app
   - Restart Terminal

2. **Grant Automation permissions:**
   ```bash
   # macOS will prompt when script first runs
   # Allow Terminal to control System Events
   ```

3. **Reset permissions if needed:**
   ```bash
   tccutil reset AppleEvents
   # Rerun install.sh and approve prompts
   ```

### LaunchAgent Fails to Load

**Problem:** `launchctl load` returns "Load failed: 5: Input/output error"

**Solutions:**

```bash
# 1. Unload any existing instance
launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist 2>/dev/null

# 2. Wait a moment
sleep 2

# 3. Load again
launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist

# 4. Or use the install script which handles this
./install.sh
```

### Logs Are Empty

**Problem:** No entries in `/tmp/check_wallpaper.log`

**This is normal!** The script only logs when:
- MDM changes your wallpaper AND
- The new path matches the TARGET in check_and_fix_wallpaper.sh

To test if logging works:
```bash
# Run script manually and check exit code
cd macos-anti-mdm-wallpaper
./check_and_fix_wallpaper.sh
echo $?  # Should be 0 (success)
```

### Script Runs But Nothing Happens

**Problem:** Service is running but no wallpaper restoration occurs

**Diagnosis:**
```bash
# 1. Check current wallpaper
cd macos-anti-mdm-wallpaper
./current_wallpaper.sh

# 2. Check what MDM path is being detected
grep TARGET check_and_fix_wallpaper.sh

# 3. Verify the paths match
# The current wallpaper must contain the TARGET string for script to activate
```

**Most common cause:** Your MDM uses a different wallpaper path than expected.

See [Different MDM Software](#different-mdm-software) section to configure.

### Getting More Debug Information

Enable verbose logging:

Edit `check_and_fix_wallpaper.sh` and add debug output:

```bash
# After line 85, add:
echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking wallpaper..."
echo "Current: $current_wallpaper"
echo "Target: $TARGET"
```

Then monitor the log:
```bash
tail -f /tmp/check_wallpaper.log
```

### Still Having Issues?

1. **Check log for errors:**
   ```bash
   cat /tmp/check_wallpaper.err
   ```

2. **Verify script permissions:**
   ```bash
   cd macos-anti-mdm-wallpaper
   ls -la *.sh
   # All should have 'x' permission: -rwxr-xr-x
   ```

3. **Test each script individually:**
   ```bash
   ./current_wallpaper.sh  # Should show your current wallpaper
   ./set_wallpaper.sh      # Should change wallpaper immediately
   ./check_and_fix_wallpaper.sh  # Should run without errors
   ```

4. **Open an issue:** Include:
   - macOS version: `sw_vers`
   - LaunchAgent status: `launchctl list | grep check_wallpaper`
   - Error logs: `/tmp/check_wallpaper.err`
   - Current wallpaper: `./current_wallpaper.sh`

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test your changes
4. Submit a pull request

## License

MIT License - Feel free to use and modify as needed.

## Credits

Created to combat corporate MDM wallpaper enforcement while maintaining personal workspace customization.

---

**⭐ If this helped you, please star the repo!**

Go to: System Settings > Privacy & Security > Automation

## License

MIT
