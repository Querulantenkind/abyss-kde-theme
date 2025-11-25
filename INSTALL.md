# Installation Guide

## Prerequisites

### System Requirements

- **OS**: Arch Linux or Arch-based distribution
- **Desktop Environment**: KDE Plasma 5 or 6 (auto-detected)
- **RAM**: 2GB minimum (4GB recommended)
- **Display**: Any resolution (wallpapers generated for multiple resolutions)

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

**Pure Monochrome (Default):**
```bash
./install-abyss.sh
```

**With Accent Color Variant:**
```bash
# Red accent
./install-abyss.sh --variant crimson

# Blue accent
./install-abyss.sh --variant cobalt

# Green accent
./install-abyss.sh --variant emerald
```

**Show Help:**
```bash
./install-abyss.sh --help
```

The script will:
- Detect your Plasma version (5 or 6)
- Check for dependencies
- Install missing packages via `pacman`
- Create theme directories
- Generate ASCII wallpapers (multiple resolutions)
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
- **Appearance -> Global Theme**: Abyss (or variant) should be listed
- **Appearance -> Colors**: Abyss color scheme available
- **Appearance -> Plasma Style**: Abyss theme visible
- **Workspace Behavior -> Splash Screen**: Verify if selected

## Theme Variants

### Available Variants

| Variant | Command | Accent Color |
|---------|---------|--------------|
| Pure Monochrome | `./install-abyss.sh` | None (default) |
| Crimson | `./install-abyss.sh -v crimson` | Deep red (#8b0000) |
| Cobalt | `./install-abyss.sh -v cobalt` | Deep blue (#0a3d62) |
| Emerald | `./install-abyss.sh -v emerald` | Deep green (#0a4a0a) |

### Installing Multiple Variants

Each variant installs as a separate theme, so you can install all of them:

```bash
./install-abyss.sh                    # Pure monochrome
./install-abyss.sh --variant crimson  # Red variant
./install-abyss.sh --variant cobalt   # Blue variant
./install-abyss.sh --variant emerald  # Green variant
```

Then switch between them in System Settings -> Appearance -> Global Theme.

### Accent Color Locations

Accent colors are applied to:
- Selection backgrounds
- Focus indicators
- Links
- Active buttons
- Progress bars
- Checkboxes and radio buttons
- SDDM login panel border
- Splash screen animation
- Wallpaper theme label

## Post-Installation

### Manual Theme Activation

If theme doesn't auto-apply:

1. Open System Settings
2. Navigate to **Appearance -> Global Theme**
3. Select **Abyss** (or Abyss-Crimson, etc.)
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

For variants, use the variant name (e.g., `Current=Abyss-Crimson`).

### GTK Theme Enforcement

For stubborn GTK applications:
```bash
# GTK2
echo 'gtk-theme-name="Abyss"' >> ~/.gtkrc-2.0

# Flatpak apps
flatpak override --user --env=GTK_THEME=Abyss
```

## Installing Extras

### Konsole Color Scheme

```bash
cp extras/konsole-profile.colorscheme ~/.local/share/konsole/Abyss.colorscheme
```

Then in Konsole: Settings -> Edit Current Profile -> Appearance -> Select "Abyss"

### Vim Color Scheme

```bash
mkdir -p ~/.vim/colors
cp extras/vim-colorscheme ~/.vim/colors/abyss.vim
```

Add to your `.vimrc`:
```vim
colorscheme abyss
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
sudo pacman -S imagemagick qt5-graphicaleffects qt5-quickcontrols qt5-quickcontrols2 breeze breeze-gtk
```

**Optional GTK2 support (from AUR):**
```bash
yay -S gtk-engine-murrine
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
# Plasma 5
kquitapp5 plasmashell
kstart5 plasmashell

# Plasma 6
kquitapp6 plasmashell
kstart6 plasmashell
```

### Script Fails Mid-Installation

The script is idempotent - simply run it again:
```bash
./install-abyss.sh
```

It will skip completed steps and resume.

### Wallpaper Generation Fails

If ASCII wallpaper doesn't generate properly:

1. Ensure ImageMagick is installed: `pacman -Qi imagemagick`
2. Check if a suitable font exists: `fc-list | grep -i mono`
3. The script will fall back to a plain black wallpaper with theme label

## Uninstallation

To remove the theme:

```bash
chmod +x uninstall-abyss.sh
./uninstall-abyss.sh
```

Options:
- `-y` - Skip confirmation
- `--keep-wallpaper` - Keep wallpaper files
- `--keep-gtk` - Keep GTK theme
- `--keep-sddm` - Skip SDDM removal
- `--no-reset` - Don't reset settings to Breeze

See [docs/UNINSTALL.md](docs/UNINSTALL.md) for detailed instructions.

## Next Steps

After successful installation:

1. Read [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for customization
2. Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) if issues arise
3. Install extras from the `extras/` directory
4. Try different accent variants

---

**Questions?** Open an issue on GitHub.
