# Troubleshooting Guide

## Common Issues and Solutions

### Installation Issues

#### Dependencies Fail to Install

**Problem**: `pacman` errors during dependency installation

**Solution**:
```bash
# Update system first
sudo pacman -Syu

# Manually install dependencies
sudo pacman -S imagemagick qt5-graphicaleffects qt5-quickcontrols qt5-quickcontrols2 breeze breeze-gtk

# Optional: GTK2 theming support (from AUR)
yay -S gtk-engine-murrine

# Run script again
./install-abyss.sh
```

#### Script Permission Denied

**Problem**: `bash: ./install-abyss.sh: Permission denied`

**Solution**:
```bash
chmod +x install-abyss.sh
./install-abyss.sh
```

#### SDDM Theme Installation Fails

**Problem**: `sudo: command not found` or permission errors

**Solution**:
```bash
# Install sudo if missing
su -
pacman -S sudo
visudo  # Add your user to sudoers

# Or manually install SDDM theme
su -
mkdir -p /usr/share/sddm/themes/Abyss
# Copy files from temporary location shown in script output
```

### Theme Application Issues

#### Theme Doesn't Apply After Installation

**Problem**: Plasma still shows default Breeze theme

**Solution 1 - Restart Plasma**:
```bash
killall plasmashell && plasmashell &
```

**Solution 2 - Manual Theme Selection**:
1. Open System Settings
2. Appearance → Global Theme
3. Select "Abyss"
4. Click "Apply"

**Solution 3 - Force Apply**:
```bash
lookandfeeltool -a com.github.abyss
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Abyss"
kwriteconfig5 --file plasmarc --group Theme --key name "Abyss"
killall plasmashell && plasmashell &
```

#### Partial Theme Application

**Problem**: Some elements are black, others still colored

**Solution**:
```bash
# Reapply all settings
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "Abyss"
kwriteconfig5 --file kdeglobals --group Icons --key Theme "breeze-dark"
kwriteconfig5 --file plasmarc --group Theme --key name "Abyss"

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

#### Plasma Crashes After Theme Application

**Problem**: Plasma shell crashes or becomes unresponsive

**Solution**:
```bash
# Safe restart from TTY (Ctrl+Alt+F2)
kquitapp5 plasmashell
rm ~/.cache/plasma*  # Clear cache
kstart5 plasmashell

# If still broken, revert to Breeze
lookandfeeltool -a org.kde.breeze.desktop
```

### SDDM Issues

#### SDDM Theme Not Applied

**Problem**: Login screen still shows default theme

**Solution 1 - Check Configuration**:
```bash
cat /etc/sddm.conf | grep -A2 "\[Theme\]"
# Should show: Current=Abyss
```

**Solution 2 - Manual Configuration**:
```bash
sudo nano /etc/sddm.conf.d/abyss.conf
```

Add:
```ini
[Theme]
Current=Abyss
```

**Solution 3 - Verify Theme Installation**:
```bash
ls /usr/share/sddm/themes/Abyss
# Should list: Main.qml, theme.conf, background.png, metadata.desktop
```

#### SDDM Shows Black Screen with No UI

**Problem**: SDDM launches but shows only black screen

**Solution**:
```bash
# Check SDDM logs
journalctl -u sddm -b

# Test SDDM theme syntax
sddm-greeter --test-mode --theme /usr/share/sddm/themes/Abyss

# If QML errors, reinstall theme
./install-abyss.sh
```

### GTK Application Issues

#### GTK Apps Don't Respect Theme

**Problem**: Firefox, GIMP, or other GTK apps still use default theme

**Solution 1 - Verify GTK Config**:
```bash
cat ~/.config/gtk-3.0/settings.ini | grep gtk-theme-name
# Should show: gtk-theme-name=Abyss
```

**Solution 2 - Force GTK Theme**:
```bash
# GTK2
echo 'gtk-theme-name="Abyss"' >> ~/.gtkrc-2.0

# GTK3
gsettings set org.gnome.desktop.interface gtk-theme "Abyss"

# Restart applications
```

**Solution 3 - For Flatpak Apps**:
```bash
flatpak override --user --env=GTK_THEME=Abyss
flatpak override --user --filesystem=~/.themes
```

#### GTK3 Apps Show Colored Elements

**Problem**: Some GTK3 widgets still show color

**Solution**:
```bash
# Add to GTK3 CSS
echo '* { accent-color: #111111; }' >> ~/.themes/Abyss/gtk-3.0/gtk.css

# Force dark mode
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
```

### Wallpaper Issues

#### Wallpaper Not Generated

**Problem**: Black wallpaper without ASCII art

**Solution**:
```bash
# Check ImageMagick installation
convert --version

# Manually generate wallpaper
cd ~/abyss-kde-theme
bash -x install-abyss.sh 2>&1 | grep -A20 "Generating ASCII"

# Check output
ls ~/.local/share/wallpapers/Abyss/contents/images/
```

#### Wallpaper Wrong Resolution

**Problem**: Wallpaper stretched or cropped

**Solution**:
Edit `install-abyss.sh` before running:
```bash
# Find line with: convert -size 1920x1080
# Change to your resolution
convert -size 2560x1440 xc:black \
```

Then regenerate:
```bash
./install-abyss.sh
```

#### ASCII Characters Don't Display

**Problem**: Wallpaper shows boxes instead of ASCII

**Solution**:
```bash
# Install font with full Unicode support
sudo pacman -S ttf-dejavu ttf-liberation noto-fonts

# Verify font
fc-list | grep -i "dejavu"

# Regenerate wallpaper
rm ~/.local/share/wallpapers/Abyss/contents/images/1920x1080.png
./install-abyss.sh
```

### Performance Issues

#### Plasma Shell High CPU Usage

**Problem**: `plasmashell` consuming excessive CPU

**Solution**:
```bash
# Disable animations
kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed 0

# Disable desktop effects
kwriteconfig5 --file kwinrc --group Plugins --key kwin4_effect_fadeEnabled false

# Restart KWin
kwin_x11 --replace &
```

#### Slow Theme Switching

**Problem**: Theme takes long time to apply

**Solution**:
```bash
# Clear Plasma cache
rm -rf ~/.cache/plasma*
rm -rf ~/.cache/kioexec*
rm -rf ~/.cache/icon-cache.kcache

# Restart Plasma
killall plasmashell && plasmashell &
```

### Color Issues

#### Some UI Elements Still Colored

**Problem**: Accent colors still appear in certain widgets

**Solution**:
```bash
# Force accent color removal
kwriteconfig5 --file kdeglobals --group General --key AccentColor "17,17,17"
kwriteconfig5 --file kdeglobals --group WM --key activeBackground "0,0,0"

# Disable accent color from wallpaper
kwriteconfig5 --file plasmarc --group Theme --key accentColorFromWallpaper false

# Restart
killall plasmashell && plasmashell &
```

#### Text Unreadable (Black on Black)

**Problem**: Some text appears invisible

**Solution**:
Edit `install-abyss.sh` and increase gray values:
```bash
COLOR_GRAY2="#151515"  # Instead of #0a0a0a
COLOR_GRAY3="#1a1a1a"  # Instead of #111111
```

Reinstall:
```bash
./install-abyss.sh
```

### System-Specific Issues

#### Acer Aspire Lite 15 Specific

**Display Flickering**:
```bash
# Add to kernel parameters
sudo nano /etc/default/grub
# Add: i915.enable_psr=0
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Low RAM Warning**:
```bash
# Disable search indexing
balooctl disable

# Reduce animations
kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed 0
```

## Diagnostic Commands

### Check Theme Installation
```bash
# Plasma theme
ls ~/.local/share/plasma/desktoptheme/Abyss/

# Color scheme
ls ~/.local/share/color-schemes/Abyss.colors

# GTK themes
ls ~/.themes/Abyss/

# SDDM theme
ls /usr/share/sddm/themes/Abyss/

# Wallpaper
ls ~/.local/share/wallpapers/Abyss/contents/images/
```

### Check Active Settings
```bash
# Current Plasma theme
kreadconfig5 --file plasmarc --group Theme --key name

# Current color scheme
kreadconfig5 --file kdeglobals --group General --key ColorScheme

# Current GTK theme
cat ~/.config/gtk-3.0/settings.ini | grep gtk-theme-name
```

### Collect Logs
```bash
# Plasma logs
journalctl --user -u plasma-plasmashell -b

# SDDM logs
sudo journalctl -u sddm -b

# X11 logs
cat ~/.local/share/xorg/Xorg.0.log

# KWin logs
journalctl --user -u plasma-kwin_x11 -b
```

## Getting Help

If issues persist:

1. **Check Logs**: Collect diagnostic output above
2. **Test Fresh Install**: Try in VM or test user
3. **Open GitHub Issue**: Include:
   - System info (`uname -a`, `plasmashell --version`)
   - Error messages
   - Steps to reproduce

### Reporting Bugs

Use this template when opening an issue:
```markdown
**System Information:**
- OS: Arch Linux
- Kernel: (output of `uname -r`)
- Plasma: (output of `plasmashell --version`)
- Qt: (output of `qmake --version`)

**Problem Description:**
Clear description of the issue

**Steps to Reproduce:**
1. Step one
2. Step two

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Logs:**
```
paste relevant logs here
```

**Screenshots:**
If applicable
```

## Emergency Reset

### Complete Theme Removal
```bash
# Remove theme files
rm -rf ~/.local/share/plasma/desktoptheme/Abyss
rm -rf ~/.local/share/plasma/look-and-feel/com.github.abyss
rm -rf ~/.local/share/color-schemes/Abyss.colors
rm -rf ~/.local/share/wallpapers/Abyss
rm -rf ~/.themes/Abyss

# Reset to Breeze
lookandfeeltool -a org.kde.breeze.desktop

# Clear cache
rm -rf ~/.cache/plasma*

# Restart
killall plasmashell && plasmashell &
```

See [UNINSTALL.md](UNINSTALL.md) for complete removal procedure.

---

**Still stuck?** Open an issue: [GitHub Issues](https://github.com/YOUR_USERNAME/abyss-kde-theme/issues)