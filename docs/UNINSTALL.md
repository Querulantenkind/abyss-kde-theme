# Uninstallation Guide

## Quick Uninstall

### Automated Removal (Coming Soon)

An uninstall script is planned for future releases.

### Manual Removal

Complete removal of Abyss theme components.

## Step-by-Step Uninstallation

### 1. Revert to Default Theme
```bash
# Switch to Breeze theme
lookandfeeltool -a org.kde.breeze.desktop

# Reset color scheme
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Breeze"

# Reset Plasma theme
kwriteconfig5 --file plasmarc --group Theme --key name "default"

# Reset icon theme
kwriteconfig5 --file kdeglobals --group Icons --key Theme "breeze"

# Restart Plasma
killall plasmashell && plasmashell &
```

### 2. Remove Theme Files
```bash
# Plasma desktop theme
rm -rf ~/.local/share/plasma/desktoptheme/Abyss

# Look-and-Feel package
rm -rf ~/.local/share/plasma/look-and-feel/com.github.abyss

# Color scheme
rm -f ~/.local/share/color-schemes/Abyss.colors

# Wallpaper
rm -rf ~/.local/share/wallpapers/Abyss

# GTK themes
rm -rf ~/.themes/Abyss
```

### 3. Reset GTK Configuration
```bash
# GTK3
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=breeze
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-application-prefer-dark-theme=0
EOF

# GTK4
cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=breeze
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
EOF

# GTK2
rm -f ~/.gtkrc-2.0
```

### 4. Remove SDDM Theme
```bash
# Remove theme directory
sudo rm -rf /usr/share/sddm/themes/Abyss

# Reset SDDM configuration
sudo rm -f /etc/sddm.conf.d/abyss.conf

# If you modified /etc/sddm.conf directly
sudo nano /etc/sddm.conf
# Remove or comment out: Current=Abyss under [Theme]
# Or set to default: Current=breeze
```

### 5. Clear Plasma Cache
```bash
# Remove cached files
rm -rf ~/.cache/plasma*
rm -rf ~/.cache/kioexec*
rm -rf ~/.cache/icon-cache.kcache

# Remove session cache
rm -rf ~/.local/share/kactivitymanagerd
```

### 6. Restart System

For complete cleanup, especially SDDM:
```bash
reboot
```

## Partial Removal

### Keep Wallpaper Only
```bash
# Remove everything except wallpaper
rm -rf ~/.local/share/plasma/desktoptheme/Abyss
rm -rf ~/.local/share/plasma/look-and-feel/com.github.abyss
rm -rf ~/.local/share/color-schemes/Abyss.colors
rm -rf ~/.themes/Abyss
sudo rm -rf /usr/share/sddm/themes/Abyss

# Keep: ~/.local/share/wallpapers/Abyss
```

Then set wallpaper manually in System Settings.

### Keep GTK Theme Only
```bash
# Remove Plasma components
rm -rf ~/.local/share/plasma/desktoptheme/Abyss
rm -rf ~/.local/share/plasma/look-and-feel/com.github.abyss
rm -rf ~/.local/share/color-schemes/Abyss.colors
rm -rf ~/.local/share/wallpapers/Abyss
sudo rm -rf /usr/share/sddm/themes/Abyss

# Keep: ~/.themes/Abyss
```

GTK apps will continue using Abyss theme.

## Troubleshooting Uninstallation

### Theme Still Appears in System Settings

**Problem**: Abyss listed even after file removal

**Solution**:
```bash
# Clear KDE service cache
kbuildsycoca5 --noincremental

# Restart System Settings
killall systemsettings5
```

### SDDM Still Shows Abyss

**Problem**: Login screen unchanged after removal

**Solution**:
```bash
# Verify SDDM config
cat /etc/sddm.conf | grep Current

# Force reset
echo -e "[Theme]\nCurrent=breeze" | sudo tee /etc/sddm.conf.d/default.conf

# Reboot
sudo reboot
```

### GTK Apps Still Use Black Theme

**Problem**: GTK applications don't revert to Breeze

**Solution**:
```bash
# Force GTK theme reset
gsettings set org.gnome.desktop.interface gtk-theme "Breeze"

# Restart GTK apps
killall firefox  # Example
```

### Flatpak Apps Still Themed

**Problem**: Flatpak applications unchanged

**Solution**:
```bash
# Reset Flatpak GTK override
flatpak override --user --reset
```

### Some UI Elements Still Black

**Problem**: Residual black colors in UI

**Solution**:
```bash
# Force full reset
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Breeze"
kwriteconfig5 --file kdeglobals --group Colors:Window --key BackgroundNormal "239,240,241"

# Clear all caches
rm -rf ~/.cache/*
rm -rf ~/.local/share/kactivitymanagerd

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

## Verification

### Confirm Complete Removal
```bash
# Check for Abyss files
find ~ -name "*abyss*" -o -name "*Abyss*" 2>/dev/null

# Check system directories
sudo find /usr/share -name "*abyss*" -o -name "*Abyss*" 2>/dev/null

# Should return empty or only repository clone
```

### Verify Theme Reset
```bash
# Check active Plasma theme
kreadconfig5 --file plasmarc --group Theme --key name
# Should show: default or breeze

# Check active color scheme
kreadconfig5 --file kdeglobals --group General --key ColorScheme
# Should show: Breeze

# Check GTK theme
cat ~/.config/gtk-3.0/settings.ini | grep gtk-theme-name
# Should show: gtk-theme-name=Breeze
```

## Preserving Abyss for Future Use

If you want to temporarily switch away but keep Abyss installed:
```bash
# Just switch to Breeze
lookandfeeltool -a org.kde.breeze.desktop

# Switch back to Abyss later
lookandfeeltool -a com.github.abyss
```

No need to remove files.

## Dependencies

Uninstalling Abyss does NOT remove dependencies:
- ImageMagick
- Qt5 packages
- GTK engines
- Breeze themes

To remove dependencies (not recommended):
```bash
# Only do this if you're sure
sudo pacman -Rs imagemagick gtk-engine-murrine gtk-engines
```

This may break other themes or applications.

## Feedback

If you're uninstalling due to issues, please consider:

1. Checking [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Opening a GitHub issue to help improve Abyss
3. Sharing feedback before complete removal

## Complete System Reset

For absolute cleanup (nuclear option):
```bash
# Remove all theme customizations
rm -rf ~/.local/share/plasma
rm -rf ~/.local/share/color-schemes
rm -rf ~/.themes
rm -rf ~/.config/gtk-*
rm -rf ~/.cache/*

# This will reset ALL Plasma customizations, not just Abyss
# Reboot required
```

**Warning**: This removes all custom themes and settings.

## Post-Uninstallation

After uninstalling:

1. Verify Plasma is stable
2. Check GTK apps render correctly
3. Confirm SDDM shows default theme (reboot)
4. Reconfigure any custom settings lost in cleanup

---

**Reconsidering?** Abyss can be reinstalled anytime: `./install-abyss.sh`