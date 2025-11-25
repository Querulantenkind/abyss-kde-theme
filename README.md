# Abyss KDE Theme

A pure monochrome KDE Plasma theme that transforms your desktop into a mysterious, minimalist void. Features deep black backgrounds with minimal gray accents and crisp white text.

![Abyss Desktop](screenshots/desktop.png)

## Features

- **Pure Monochrome Aesthetic**: Black (#000000) base with surgical gray accents
- **Complete System Integration**: 
  - Plasma Desktop Theme
  - SDDM Login Manager Theme
  - GTK2/GTK3/GTK4 Application Themes
  - Custom Color Scheme
  - Animated Splash Screen
- **Cryptic ASCII Wallpaper**: Generated geometric structures (1920x1080)
- **Lightweight**: Optimized for low-resource systems
- **Idempotent Installation**: Safe to run multiple times

## Preview

| Component | Preview |
|-----------|---------|
| Desktop | ![Desktop](screenshots/desktop.png) |
| SDDM Login | ![SDDM](screenshots/sddm.png) |
| Splash Screen | ![Splash](screenshots/splash.png) |
| ASCII Wallpaper | ![Wallpaper](screenshots/ascii-wallpaper.png) |

## Requirements

- Arch Linux (or Arch-based distribution)
- KDE Plasma 5/6
- `sudo` privileges for SDDM theme installation

### Dependencies

The script will automatically install required packages:
- `imagemagick` - Wallpaper generation
- `qt5-graphicaleffects` / `qt5-quickcontrols` / `qt5-quickcontrols2`
- `breeze` / `breeze-gtk`

**Optional (for GTK2 apps):** `gtk-engine-murrine` - available in AUR: `yay -S gtk-engine-murrine`

## Installation

### Quick Install
```bash
git clone https://github.com/YOUR_USERNAME/abyss-kde-theme.git
cd abyss-kde-theme
chmod +x install-abyss.sh
./install-abyss.sh
```

### Post-Installation

1. **Restart Plasma Shell**:
```bash
   killall plasmashell && plasmashell &
```

2. **Or reboot** for complete SDDM theme application

3. **Manual Theme Selection** (if needed):
   - System Settings → Appearance → Global Theme → **Abyss**

### Detailed Installation Guide

See [INSTALL.md](INSTALL.md) for step-by-step instructions and customization options.

## What Gets Installed

The script creates the following structure in your home directory:
```
~/.local/share/
├── plasma/
│   ├── desktoptheme/Abyss/
│   └── look-and-feel/com.github.abyss/
├── color-schemes/Abyss.colors
└── wallpapers/Abyss/

~/.themes/Abyss/
├── gtk-2.0/
├── gtk-3.0/
└── gtk-4.0/

~/.config/
├── gtk-3.0/settings.ini
└── gtk-4.0/settings.ini

/usr/share/sddm/themes/Abyss/  # Requires sudo
```

## Configuration

### Color Palette

| Color | Hex Code | Usage |
|-------|----------|-------|
| Pure Black | `#000000` | Primary background |
| Deep Gray 1 | `#050505` | Subtle backgrounds |
| Deep Gray 2 | `#0a0a0a` | UI elements |
| Deep Gray 3 | `#111111` | Borders, accents |
| Pure White | `#ffffff` | Text, icons |

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

## Uninstallation

See [docs/UNINSTALL.md](docs/UNINSTALL.md) for removal instructions.

## Troubleshooting

Common issues and solutions are documented in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

### Quick Fixes

**Plasma doesn't update after installation:**
```bash
kquitapp5 plasmashell && kstart5 plasmashell
```

**GTK apps don't respect theme:**
- Verify `~/.config/gtk-3.0/settings.ini` exists
- Restart GTK applications

**SDDM theme not applied:**
```bash
sudo nano /etc/sddm.conf
# Set: Current=Abyss under [Theme]
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

## Credits

- Created as part of the [Terminal Purist System](https://github.com/YOUR_USERNAME/terminal-purist-system) project
- Inspired by monochrome aesthetics and cyberpunk minimalism

## Roadmap

- [ ] Kvantum theme integration
- [ ] Aurorae window decoration theme
- [ ] Konsole color scheme export
- [ ] KRunner theme
- [ ] Conky configuration
- [ ] System tray icon customization

## Gallery

*Submit your Abyss desktop screenshots via PR!*

---

**Enter the void. Embrace the abyss.**
```

### LICENSE
```
MIT License

Copyright (c) 2025 Abyss Theme

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
