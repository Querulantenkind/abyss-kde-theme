# Configuration Guide

## Overview

Abyss is designed to be minimalist and opinionated, but several aspects can be customized. The theme now supports accent color variants and automatically generates wallpapers for multiple resolutions.

## Theme Variants

### Using Built-in Variants

The easiest way to get accent colors is to use the built-in variants:

```bash
./install-abyss.sh                    # Pure monochrome
./install-abyss.sh --variant crimson  # Red accents
./install-abyss.sh --variant cobalt   # Blue accents
./install-abyss.sh --variant emerald  # Green accents
```

### Accent Color Palettes

| Variant | Primary | Dim | Bright |
|---------|---------|-----|--------|
| Crimson | #8b0000 | #4a0000 | #cc0000 |
| Cobalt | #0a3d62 | #051d30 | #1e6fa3 |
| Emerald | #0a4a0a | #052505 | #0d6b0d |

### Creating Custom Accent Colors

Edit `install-abyss.sh` and modify the `set_variant_colors()` function to add your own variant:

```bash
set_variant_colors() {
    local variant="${1:-}"
    
    case "$variant" in
        # Add your custom variant
        purple|violet)
            THEME_VARIANT="Violet"
            COLOR_ACCENT="#4a0080"
            COLOR_ACCENT_DIM="#2a0050"
            COLOR_ACCENT_BRIGHT="#7b00d4"
            ;;
        # ... existing variants
    esac
}
```

Then install with: `./install-abyss.sh --variant purple`

## Color Customization

### Base Color Palette

Edit `install-abyss.sh` before running:

```bash
# CONFIGURATION SECTION (around line 23)

# Color palette (base monochrome)
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
| Buttons (hover) | `COLOR_ACCENT_DIM` | Varies by variant |
| Borders | `COLOR_GRAY3` | #111111 |
| Selection | `COLOR_ACCENT` | Varies by variant |
| Links | `COLOR_ACCENT_BRIGHT` | Varies by variant |
| Focus indicators | `COLOR_ACCENT` | Varies by variant |

## Wallpaper Customization

### Multi-Resolution Support (Built-in)

The script now automatically generates wallpapers for multiple resolutions:
- 1920x1080 (Full HD)
- 2560x1440 (2K/QHD)
- 3840x2160 (4K/UHD)
- 1366x768 (Laptop)

KDE will automatically select the appropriate resolution.

### Adding Custom Resolutions

Edit the `generate_ascii_wallpaper()` function:

```bash
generate_ascii_wallpaper() {
    # Add your resolution to the array
    local resolutions=("1920x1080" "2560x1440" "3840x2160" "1366x768" "3440x1440")
    # ...
}
```

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

The script auto-scales font size based on resolution. To change the base size, modify:

```bash
# Scale pointsize based on resolution
local pointsize=$((12 * width / 1920))  # Change 12 to your base size
```

## Component-Specific Configuration

### Plasma Panel

Modify panel opacity in `create_plasma_theme()`:

```bash
# In widgets/panel-background.svg
<rect width="100" height="100" fill="#000000" opacity="0.95"/>
#                                              ^^ Change (0.0-1.0)
```

### SDDM Login Screen

Customize SDDM appearance in `create_sddm_theme()`:

```qml
// Login panel size
Rectangle {
    id: loginPanel
    width: 400   // Change width
    height: 280  // Change height
}

// Font sizes
font.pointSize: 24  // Title size
font.pointSize: 12  // Input size
```

The SDDM theme now uses accent colors for:
- Login panel border
- Login button background
- Focus indicators on fields

### GTK Applications

The GTK theme now includes accent color support:

```css
/* Selection uses accent color */
*:selected {
    background-color: $COLOR_ACCENT;
    color: $COLOR_WHITE;
}

/* Focus uses accent color */
*:focus {
    border-color: $COLOR_ACCENT;
}

/* Links use bright accent */
link, *:link {
    color: $COLOR_ACCENT_BRIGHT;
}
```

### Splash Screen

The splash screen now displays the theme name and uses accent colors:

```qml
Rectangle {
    id: topRect
    color: "$COLOR_ACCENT_BRIGHT"  // Animated bar color
}

Text {
    text: "$THEME_NAME"  // Shows "Abyss" or "Abyss-Crimson" etc.
}
```

## Configuration Files Locations

After installation, theme files are located at:

```
~/.local/share/plasma/
├── desktoptheme/Abyss/           # (or Abyss-Crimson, etc.)
│   ├── metadata.desktop
│   ├── colors
│   └── widgets/
├── look-and-feel/com.github.abyss/
│   └── contents/
│       ├── defaults
│       └── splash/
│           └── Splash.qml
└── wallpapers/Abyss/
    ├── metadata.json
    └── contents/images/
        ├── 1920x1080.png
        ├── 2560x1440.png
        ├── 3840x2160.png
        └── 1366x768.png

~/.local/share/color-schemes/
└── Abyss.colors                  # (or Abyss-Crimson.colors)

~/.themes/Abyss/                  # (or Abyss-Crimson)
├── gtk-2.0/gtkrc
├── gtk-3.0/gtk.css
└── gtk-4.0/gtk.css

~/.config/
├── gtk-3.0/settings.ini
└── gtk-4.0/settings.ini

/usr/share/sddm/themes/Abyss/     # (or Abyss-Crimson)
```

## Runtime Configuration

### Plasma Settings (Without Reinstalling)

```bash
# For Plasma 5
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Abyss"
kwriteconfig5 --file plasmarc --group Theme --key name "Abyss"

# For Plasma 6
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "Abyss"
kwriteconfig6 --file plasmarc --group Theme --key name "Abyss"

# Reload Plasma
killall plasmashell && plasmashell &
```

### Switching Between Variants

If you've installed multiple variants, switch via:
- System Settings -> Appearance -> Global Theme
- Or command line:

```bash
# Plasma 5
lookandfeeltool -a com.github.abyss.crimson

# Plasma 6
plasma-apply-lookandfeel -a com.github.abyss.crimson
```

### GTK Settings (Without Reinstalling)

```bash
# GTK3
gsettings set org.gnome.desktop.interface gtk-theme "Abyss-Crimson"

# Or edit directly
nano ~/.config/gtk-3.0/settings.ini
```

## Reverting Changes

### Reset to Breeze

```bash
# Plasma 5
lookandfeeltool -a org.kde.breeze.desktop
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Breeze"
kwriteconfig5 --file plasmarc --group Theme --key name "default"

# Plasma 6
plasma-apply-lookandfeel -a org.kde.breeze.desktop
kwriteconfig6 --file kdeglobals --group General --key ColorScheme "Breeze"
kwriteconfig6 --file plasmarc --group Theme --key name "default"
```

### Remove Theme Files

Use the uninstall script:

```bash
./uninstall-abyss.sh
```

Or see [UNINSTALL.md](UNINSTALL.md) for manual removal.

## Tips

- **Test in VM First**: Changes are immediate and system-wide
- **Backup Configs**: Copy `~/.config/plasma*` before major changes
- **Incremental Changes**: Modify one component at a time
- **Check Logs**: Run script with `bash -x install-abyss.sh` for debugging
- **Install Multiple Variants**: They coexist peacefully
- **Customize After Installing**: Modify files directly in `~/.local/share/`

---

**Questions?** Open an issue on GitHub.
