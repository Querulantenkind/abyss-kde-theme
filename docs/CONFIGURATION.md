# Configuration Guide

## Overview

Abyss is designed to be minimalist and opinionated, but several aspects can be customized.

## Color Customization

### Modifying the Color Palette

Edit `install-abyss.sh` before running:
```bash
# CONFIGURATION SECTION (around line 15)
THEME_NAME="Abyss"

# Color palette
COLOR_BLACK="#000000"   # Primary background
COLOR_WHITE="#ffffff"   # Text and icons
COLOR_GRAY1="#050505"   # Subtle backgrounds
COLOR_GRAY2="#0a0a0a"   # UI elements
COLOR_GRAY3="#111111"   # Borders and accents
```

### Color Usage Map

| Element | Color Variable | Default Hex |
|---------|---------------|-------------|
| Desktop background | `COLOR_BLACK` | #000000 |
| Panel background | `COLOR_BLACK` | #000000 |
| Window background | `COLOR_BLACK` | #000000 |
| Text | `COLOR_WHITE` | #ffffff |
| Buttons (normal) | `COLOR_GRAY2` | #0a0a0a |
| Buttons (hover) | `COLOR_GRAY3` | #111111 |
| Borders | `COLOR_GRAY3` | #111111 |
| Selection | `COLOR_GRAY3` | #111111 |

## Wallpaper Customization

### Resolution

Change wallpaper size in `generate_ascii_wallpaper()`:
```bash
convert -size 1920x1080 xc:black \  # Modify this line
    -font "DejaVu-Sans-Mono" \
    -pointsize 12 \
    # ...
```

Common resolutions:
- 1920x1080 (Full HD)
- 2560x1440 (2K)
- 3840x2160 (4K)
- 1366x768 (Laptop)

### ASCII Pattern

Replace the pattern in the heredoc:
```bash
cat > /tmp/abyss_ascii.txt << 'EOF'
    # Your custom ASCII art here
    # Use box-drawing characters: ─│┌┐└┘├┤┬┴┼
    # Use block characters: ░▒▓█▄▀
    # Use geometric shapes: ◢◣◤◥◸◹◺◿
EOF
```

### Font and Size

Modify ImageMagick parameters:
```bash
convert -size 1920x1080 xc:black \
    -font "DejaVu-Sans-Mono" \      # Change font
    -pointsize 12 \                  # Change size
    -fill white \                    # Text color
    -annotate +100+100 "@/tmp/abyss_ascii.txt" \  # Position
    "$wallpaper_path"
```

## Component-Specific Configuration

### Plasma Panel

Modify panel opacity in `create_plasma_theme()`:
```bash
# In widgets/panel-background.svg
<rect width="100" height="100" fill="#000000" opacity="0.95"/>
                                              # ^^ Change this value (0.0-1.0)
```

### SDDM Login Screen

Customize SDDM appearance in `create_sddm_theme()`:
```javascript
// In Main.qml

// Login panel size
Rectangle {
    id: loginPanel
    width: 400   // Change width
    height: 200  // Change height
    // ...
}

// Font size
font.pointSize: 24  // Change title size
font.pointSize: 12  // Change input size
```

### GTK Applications

Fine-tune GTK styling in `create_gtk_themes()`:
```css
/* In gtk-3.0/gtk.css */

* {
    background-color: #000000;  /* Base background */
    color: #ffffff;              /* Text color */
    border-color: #111111;       /* Border color */
}

button {
    background-color: #0a0a0a;   /* Button background */
    border-radius: 0px;          /* Corner rounding */
}
```

### Splash Screen

Customize boot splash in `create_lookfeel_package()`:
```qml
// In Splash.qml

Text {
    text: "ABYSS"          // Change text
    font.pointSize: 32      // Change size
    font.family: "Monospace"  // Change font
}

// Animation speed
NumberAnimation {
    duration: 1000  // Milliseconds (slower/faster)
}
```

## Advanced Customization

### Adding Custom Components

#### Example: Custom Kvantum Theme

1. **Create Function**:
```bash
create_kvantum_theme() {
    log "Creating Kvantum theme..."
    
    local kvantum_dir="$HOME/.config/Kvantum/Abyss"
    mkdir -p "$kvantum_dir"
    
    cat > "$kvantum_dir/Abyss.kvconfig" << EOF
[General]
author=Abyss
comment=Pure monochrome theme
# ... configuration
EOF
}
```

2. **Call in Main Execution**:
```bash
main() {
    # ... existing functions
    create_kvantum_theme
}
```

### Multi-Resolution Support

Modify wallpaper generation to create multiple sizes:
```bash
generate_ascii_wallpaper() {
    local resolutions=("1920x1080" "2560x1440" "3840x2160")
    
    for res in "${resolutions[@]}"; do
        convert -size "$res" xc:black \
            # ... rest of command
            "$WALLPAPER_DIR/contents/images/$res.png"
    done
}
```

## Configuration Files Locations

After installation, theme files are located at:
```
~/.local/share/plasma/
├── desktoptheme/Abyss/
│   ├── metadata.desktop
│   ├── colors
│   └── widgets/
├── look-and-feel/com.github.abyss/
│   └── contents/
└── wallpapers/Abyss/

~/.local/share/color-schemes/
└── Abyss.colors

~/.themes/Abyss/
├── gtk-2.0/gtkrc
├── gtk-3.0/gtk.css
└── gtk-4.0/gtk.css

~/.config/
├── gtk-3.0/settings.ini
└── gtk-4.0/settings.ini

/usr/share/sddm/themes/Abyss/
```

## Runtime Configuration

### Plasma Settings (Without Reinstalling)
```bash
# Change color scheme
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Abyss"

# Change wallpaper
kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc \
    --group Containments --group 1 --group Wallpaper \
    --group org.kde.image --group General \
    --key Image "file:///path/to/wallpaper.png"

# Reload Plasma
killall plasmashell && plasmashell &
```

### GTK Settings (Without Reinstalling)
```bash
# GTK3
gsettings set org.gnome.desktop.interface gtk-theme "Abyss"

# Or edit directly
nano ~/.config/gtk-3.0/settings.ini
```

## Reverting Changes

### Reset to Breeze
```bash
lookandfeeltool -a org.kde.breeze.desktop
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Breeze"
kwriteconfig5 --file plasmarc --group Theme --key name "default"
```

### Remove Theme Files

See [UNINSTALL.md](UNINSTALL.md) for complete removal.

## Tips

- **Test in VM First**: Changes are immediate and system-wide
- **Backup Configs**: Copy `~/.config/plasma*` before major changes
- **Incremental Changes**: Modify one component at a time
- **Check Logs**: Run script with `bash -x install-abyss.sh` for debugging

---

**Questions?** Open an issue on GitHub.