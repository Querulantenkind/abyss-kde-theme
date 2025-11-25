# Installation Guide

## Prerequisites

### System Requirements

- **OS**: Arch Linux or Arch-based distribution
- **Desktop Environment**: KDE Plasma 5 or 6
- **RAM**: 2GB minimum (4GB recommended)
- **Display**: Any resolution (wallpaper optimized for 1920x1080)

### Required Permissions

The script requires:
- User-level access for theme installation
- `sudo` access for SDDM theme installation only

## Step-by-Step Installation

### 1. Clone Repository
```bash
cd ~/
git clone https://github.com/YOUR_USERNAME/abyss-kde-theme.git
cd abyss-kde-theme
```

### 2. Review Script (Optional)
```bash
less install-abyss.sh
```

The script is idempotent and safe to inspect before execution.

### 3. Make Executable
```bash
chmod +x install-abyss.sh
```

### 4. Run Installer
```bash
./install-abyss.sh
```

The script will:
- Check for dependencies
- Install missing packages via `pacman`
- Create theme directories
- Generate ASCII wallpaper
- Configure Plasma settings
- Install SDDM theme (requires sudo password)

### 5. Apply Changes

**Option A: Restart Plasma Shell**
```bash
killall plasmashell && plasmashell &
```

**Option B: Full Reboot** (Recommended for SDDM)
```bash
reboot
```

### 6. Verify Installation

Open System Settings and check:
- **Appearance → Global Theme**: Abyss should be listed
- **Appearance → Colors**: Abyss color scheme available
- **Appearance → Plasma Style**: Abyss theme visible
- **Workspace Behavior → Splash Screen**: Verify if selected

## Post-Installation

### Manual Theme Activation

If theme doesn't auto-apply:

1. Open System Settings
2. Navigate to **Appearance → Global Theme**
3. Select **Abyss**
4. Click **Apply**

### SDDM Configuration

If SDDM theme doesn't apply:
```bash
sudo nano /etc/sddm.conf
```

Ensure the following is set:
```ini
[Theme]
Current=Abyss
```

Or create configuration:
```bash
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=Abyss" | sudo tee /etc/sddm.conf.d/abyss.conf
```

### GTK Theme Enforcement

For stubborn GTK applications:
```bash
# GTK2
echo 'gtk-theme-name="Abyss"' >> ~/.gtkrc-2.0

# Flatpak apps
flatpak override --user --env=GTK_THEME=Abyss
```

## Customization During Installation

### Modify Colors

Edit `install-abyss.sh` before running:
```bash
nano install-abyss.sh
```

Locate the configuration section:
```bash
# CONFIGURATION
COLOR_BLACK="#000000"  # Change these values
COLOR_WHITE="#ffffff"
COLOR_GRAY1="#050505"
COLOR_GRAY2="#0a0a0a"
COLOR_GRAY3="#111111"
```

### Change Wallpaper Resolution

Edit the `generate_ascii_wallpaper()` function:
```bash
convert -size 2560x1440 xc:black \  # Change resolution here
```

### Modify ASCII Pattern

Edit the heredoc in `generate_ascii_wallpaper()`:
```bash
cat > /tmp/abyss_ascii.txt << 'EOF'
# Your custom ASCII art here
EOF
```

## Troubleshooting Installation

### Dependencies Fail to Install

**Manual installation:**
```bash
sudo pacman -S imagemagick qt5-graphicaleffects qt5-quickcontrols qt5-quickcontrols2 gtk-engine-murrine gtk-engines breeze breeze-gtk
```

### Permission Denied Errors

Ensure script is executable:
```bash
chmod +x install-abyss.sh
```

For SDDM theme installation, you'll be prompted for sudo password.

### Plasma Crashes After Installation

Restart Plasma safely:
```bash
kquitapp5 plasmashell
kstart5 plasmashell
```

### Script Fails Mid-Installation

The script is idempotent - simply run it again:
```bash
./install-abyss.sh
```

It will skip completed steps and resume.

## Alternative Installation Methods

### Manual Component Installation

Install individual components:

1. **Plasma Theme Only**:
```bash
   mkdir -p ~/.local/share/plasma/desktoptheme/Abyss
   # Copy theme files manually
```

2. **GTK Theme Only**:
```bash
   mkdir -p ~/.themes/Abyss/gtk-3.0
   # Copy GTK CSS files
```

3. **SDDM Only**:
```bash
   sudo mkdir -p /usr/share/sddm/themes/Abyss
   # Copy SDDM theme files
```

### Portable Installation

For testing without system modifications:
```bash
# Run with environment variable
export ABYSS_PORTABLE=1
./install-abyss.sh
```

(Note: This feature would need to be added to the script)

## Next Steps

After successful installation:

1. Read [CONFIGURATION.md](docs/CONFIGURATION.md) for customization
2. Check [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) if issues arise
3. Explore extras in `/extras` directory

---

**Questions?** Open an issue on GitHub.