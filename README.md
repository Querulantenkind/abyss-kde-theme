# Abyss KDE Theme

A pure monochrome KDE Plasma theme that transforms your desktop into a mysterious, minimalist void. Features deep black backgrounds with minimal gray accents and crisp white text. Now with optional accent color variants.

![Abyss Desktop](screenshots/desktop.png)

## Features

- **Pure Monochrome Aesthetic**: Black (#000000) base with surgical gray accents
- **Accent Color Variants**: Optional Crimson, Cobalt, or Emerald accent colors
- **Complete System Integration**: 
  - Plasma Desktop Theme
  - SDDM Login Manager Theme
  - GTK2/GTK3/GTK4 Application Themes
  - Kvantum Theme (Qt application styling)
  - Aurorae Window Decoration Theme
  - Plymouth Boot Splash Screen
  - Custom Color Scheme (proper RGB format)
  - Animated Splash Screen
- **Multi-Resolution Wallpapers**: Auto-generated for 1920x1080, 2560x1440, 3840x2160, 1366x768
- **Plasma 5 & 6 Compatible**: Auto-detects and uses appropriate commands
- **Lightweight**: Optimized for low-resource systems
- **Idempotent Installation**: Safe to run multiple times
- **Easy Uninstallation**: Includes dedicated uninstall script

## Preview

| Component | Preview |
|-----------|---------|
| Desktop | ![Desktop](screenshots/desktop.png) |
| SDDM Login | ![SDDM](screenshots/sddm.png) |
| Splash Screen | ![Splash](screenshots/splash.png) |
| ASCII Wallpaper | ![Wallpaper](screenshots/ascii-wallpaper.png) |

## Requirements

- Arch Linux (or Arch-based distribution)
- KDE Plasma 5 or 6
- `sudo` privileges for SDDM theme installation

### Dependencies

The script will automatically install required packages:
- `imagemagick` - Wallpaper generation
- `qt5-graphicaleffects` / `qt5-quickcontrols` / `qt5-quickcontrols2`
- `breeze` / `breeze-gtk`
- `kvantum` - Qt application styling
- `bc` - Math calculations for Plymouth theme

**Optional:**
- `gtk-engine-murrine` - For GTK2 apps (AUR: `yay -S gtk-engine-murrine`)
- `plymouth` - Boot splash screen (may require AUR or manual configuration)

## Installation

### Quick Install

```bash
git clone https://github.com/YOUR_USERNAME/abyss-kde-theme.git
cd abyss-kde-theme
chmod +x install-abyss.sh
./install-abyss.sh
```

### Theme Variants

Install with accent colors for a subtle splash of color:

```bash
# Pure monochrome (default)
./install-abyss.sh

# Red accent variant
./install-abyss.sh --variant crimson

# Blue accent variant
./install-abyss.sh --variant cobalt

# Green accent variant
./install-abyss.sh --variant emerald

# Show help
./install-abyss.sh --help
```

| Variant | Accent Color | Description |
|---------|-------------|-------------|
| Pure | Monochrome | Default black/white/gray |
| Crimson | #8b0000 | Deep red accents |
| Cobalt | #0a3d62 | Deep blue accents |
| Emerald | #0a4a0a | Deep green accents |

Each variant installs as a separate theme (Abyss, Abyss-Crimson, Abyss-Cobalt, Abyss-Emerald), so you can install multiple variants and switch between them in System Settings.

### Post-Installation

1. **Restart Plasma Shell**:
```bash
killall plasmashell && plasmashell &
```

2. **Or reboot** for complete SDDM and Plymouth theme application

3. **For Plymouth boot theme** (rebuild initramfs):
```bash
sudo mkinitcpio -P
```

4. **Manual Theme Selection** (if needed):
   - System Settings -> Appearance -> Global Theme -> **Abyss** (or variant name)
   - System Settings -> Appearance -> Window Decorations -> **Abyss**
   - Kvantum Manager -> Select **Abyss** theme

### Detailed Installation Guide

See [INSTALL.md](INSTALL.md) for step-by-step instructions and customization options.

## What Gets Installed

The script creates the following structure:

```
~/.local/share/
├── plasma/
│   ├── desktoptheme/Abyss/           # (or Abyss-Crimson, etc.)
│   └── look-and-feel/com.github.abyss/
├── aurorae/themes/Abyss/             # Window decoration
├── color-schemes/Abyss.colors
└── wallpapers/Abyss/
    └── contents/images/
        ├── 1920x1080.png
        ├── 2560x1440.png
        ├── 3840x2160.png
        └── 1366x768.png

~/.themes/Abyss/
├── gtk-2.0/
├── gtk-3.0/
└── gtk-4.0/

~/.config/
├── Kvantum/
│   ├── kvantum.kvconfig              # Active theme config
│   └── Abyss/                        # Kvantum theme files
│       ├── Abyss.svg
│       └── Abyss.kvconfig
├── environment.d/kvantum.conf        # Qt style override
├── gtk-3.0/settings.ini
└── gtk-4.0/settings.ini

/usr/share/sddm/themes/Abyss/         # Requires sudo
/usr/share/plymouth/themes/Abyss/     # Requires sudo (boot splash)
```

## Uninstallation

### Quick Uninstall

```bash
./uninstall-abyss.sh
```

### Uninstall Options

```bash
./uninstall-abyss.sh -y                # Skip confirmation
./uninstall-abyss.sh --keep-wallpaper  # Keep wallpaper
./uninstall-abyss.sh --keep-gtk        # Keep GTK theme
./uninstall-abyss.sh --keep-kvantum    # Keep Kvantum theme
./uninstall-abyss.sh --keep-aurorae    # Keep window decoration
./uninstall-abyss.sh --keep-sddm       # Skip SDDM removal
./uninstall-abyss.sh --keep-plymouth   # Skip Plymouth removal
./uninstall-abyss.sh --no-reset        # Don't reset to Breeze
./uninstall-abyss.sh --help            # Show all options
```

See [docs/UNINSTALL.md](docs/UNINSTALL.md) for detailed removal instructions.

## Configuration

### Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Pure Black | `#000000` | Primary background |
| Deep Gray 1 | `#050505` | Subtle backgrounds |
| Deep Gray 2 | `#0a0a0a` | UI elements |
| Deep Gray 3 | `#111111` | Borders, accents |
| Pure White | `#ffffff` | Text, icons |

### Accent Color Palettes

| Variant | Primary | Dim | Bright |
|---------|---------|-----|--------|
| Crimson | #8b0000 | #4a0000 | #cc0000 |
| Cobalt | #0a3d62 | #051d30 | #1e6fa3 |
| Emerald | #0a4a0a | #052505 | #0d6b0d |

### Customization

To modify colors, edit the configuration section in `install-abyss.sh`:

```bash
COLOR_BLACK="#000000"
COLOR_WHITE="#ffffff"
COLOR_GRAY1="#050505"
COLOR_GRAY2="#0a0a0a"
COLOR_GRAY3="#111111"
```

See [docs/CONFIGURATION.md](docs/CONFIGURATION.md) for advanced customization.

## Extras

The `extras/` directory contains additional color schemes:

| File | Description | Installation |
|------|-------------|--------------|
| `konsole-profile.colorscheme` | Konsole terminal colors | `cp extras/konsole-profile.colorscheme ~/.local/share/konsole/Abyss.colorscheme` |
| `vim-colorscheme` | Vim/Neovim colors | `cp extras/vim-colorscheme ~/.vim/colors/abyss.vim` |

## Troubleshooting

Common issues and solutions are documented in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

### Quick Fixes

**Plasma doesn't update after installation:**
```bash
kquitapp5 plasmashell && kstart5 plasmashell
# Or for Plasma 6:
kquitapp6 plasmashell && kstart6 plasmashell
```

**GTK apps don't respect theme:**
- Verify `~/.config/gtk-3.0/settings.ini` exists
- Restart GTK applications

**SDDM theme not applied:**
```bash
sudo nano /etc/sddm.conf
# Set: Current=Abyss under [Theme]
```

**Kvantum theme not applied to Qt apps:**
```bash
# Ensure QT_STYLE_OVERRIDE is set
echo 'QT_STYLE_OVERRIDE=kvantum' >> ~/.config/environment.d/kvantum.conf
# Then logout and login, or restart the application
```

**Aurorae window decoration not showing:**
- System Settings -> Appearance -> Window Decorations
- Select "Abyss" from the list
- If not visible, restart KWin: `kwin_x11 --replace &` or `kwin_wayland --replace &`

**Plymouth boot theme not showing:**
```bash
# Set the theme
sudo plymouth-set-default-theme -R Abyss
# Rebuild initramfs
sudo mkinitcpio -P
# Reboot to see the theme
```

## Philosophy

Abyss embraces **Terminal Purist** principles:
- Minimalism over decoration
- Performance over eye candy
- Mystery through absence of color
- Information density without distraction

Designed for the disciplined minimalist who appreciates the void.

## Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Roadmap

- [x] Multi-resolution wallpaper support
- [x] Plasma 5/6 compatibility
- [x] Theme accent variants
- [x] Konsole color scheme
- [x] Vim color scheme
- [x] Uninstall script
- [x] Kvantum theme integration
- [x] Aurorae window decoration theme
- [x] Plymouth boot theme
- [ ] KRunner theme
- [ ] Conky configuration
- [ ] GRUB theme

## Gallery

*Submit your Abyss desktop screenshots via PR!*

---

**Enter the void. Embrace the abyss.**
