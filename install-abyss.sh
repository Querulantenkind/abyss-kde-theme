#!/usr/bin/env bash
#
# ABYSS - KDE Plasma Monochrome Theme Installer
# Pure black desktop with minimal gray accents and white text
# Idempotent installation script for Arch Linux
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

THEME_NAME="Abyss"
THEME_DIR="$HOME/.local/share/plasma/desktoptheme/$THEME_NAME"
LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss"
SDDM_THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
GTK2_DIR="$HOME/.themes/$THEME_NAME"
GTK3_DIR="$HOME/.themes/$THEME_NAME"
WALLPAPER_DIR="$HOME/.local/share/wallpapers/$THEME_NAME"
SPLASH_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss/contents/splash"

# Color palette
COLOR_BLACK="#000000"
COLOR_WHITE="#ffffff"
COLOR_GRAY1="#050505"
COLOR_GRAY2="#0a0a0a"
COLOR_GRAY3="#111111"

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo "[ABYSS] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root. SDDM installation will use sudo when needed."
    fi
}

install_dependencies() {
    log "Checking dependencies..."
    
    local packages=(
        "imagemagick"
        "qt5-graphicaleffects"
        "qt5-quickcontrols"
        "qt5-quickcontrols2"
        "gtk-engine-murrine"
        "gtk-engines"
        "breeze"
        "breeze-gtk"
    )
    
    local missing=()
    for pkg in "${packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Installing missing dependencies: ${missing[*]}"
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    else
        log "All dependencies already installed."
    fi
}

create_directory_structure() {
    log "Creating directory structure..."
    
    mkdir -p "$THEME_DIR"/{dialogs,widgets,icons}
    mkdir -p "$LOOKFEEL_DIR"/contents/{defaults,layouts,previews,splash,components}
    mkdir -p "$GTK2_DIR"/gtk-2.0
    mkdir -p "$GTK3_DIR"/{gtk-3.0,gtk-4.0}
    mkdir -p "$WALLPAPER_DIR"/contents/images
    mkdir -p "$HOME/.local/share/color-schemes"
    mkdir -p "$HOME/.local/share/aurorae/themes"
}

generate_ascii_wallpaper() {
    log "Generating ASCII wallpaper with geometric structures..."
    
    local wallpaper_path="$WALLPAPER_DIR/contents/images/1920x1080.png"
    
    # Create ASCII art pattern
    cat > /tmp/abyss_ascii.txt << 'EOF'
        ╔════════════════════════════════════════════════════════════════╗
        ║  ▓▓▓▓▓▓▓▓░░░░░░░░▓▓▓▓▓▓▓▓  ░░░░░░░░▓▓▓▓▓▓▓▓░░░░░░░░▓▓▓▓▓▓▓▓  ║
        ║  ▓▓░░░░▓▓▓▓▓▓▓▓▓▓░░░░▓▓  ▓▓▓▓▓▓▓▓░░░░▓▓▓▓▓▓▓▓▓▓▓▓░░░░▓▓  ║
        ║    ░░▓▓░░  ░░▓▓░░    ░░▓▓░░  ░░▓▓░░    ░░▓▓░░  ░░▓▓░░    ║
        ║  ▓▓░░░░▓▓▓▓▓▓░░░░▓▓  ▓▓░░░░▓▓▓▓▓▓░░░░▓▓  ▓▓░░░░▓▓▓▓▓▓░░░░▓▓  ║
        ║  ░░▓▓▓▓░░░░░░▓▓▓▓░░  ░░▓▓▓▓░░░░░░▓▓▓▓░░  ░░▓▓▓▓░░░░░░▓▓▓▓░░  ║
        ╠════════════════════════════════════════════════════════════════╣
        ║    ◢◣◢◣    ◢◣◢◣    ◢◣◢◣    ◢◣◢◣    ◢◣◢◣    ◢◣◢◣    ◢◣◢◣    ║
        ║    ◥◤◥◤    ◥◤◥◤    ◥◤◥◤    ◥◤◥◤    ◥◤◥◤    ◥◤◥◤    ◥◤◥◤    ║
        ║  ╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲  ║
        ║  ╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱╲╱  ║
        ╠════════════════════════════════════════════════════════════════╣
        ║  ┌─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┬─┐  ║
        ║  ├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤  ║
        ║  ├─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┼─┤  ║
        ║  └─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┴─┘  ║
        ║    ▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄    ║
        ║    ▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀    ║
        ╠════════════════════════════════════════════════════════════════╣
        ║  ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗ ╔══╗  ║
        ║  ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║ ║▓▓║  ║
        ║  ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝ ╚══╝  ║
        ╚════════════════════════════════════════════════════════════════╝
EOF
    
    # Convert ASCII to image with ImageMagick
    convert -size 1920x1080 xc:black \
        -font "DejaVu-Sans-Mono" \
        -pointsize 12 \
        -fill white \
        -annotate +100+100 "@/tmp/abyss_ascii.txt" \
        "$wallpaper_path"
    
    # Create metadata
    cat > "$WALLPAPER_DIR/metadata.json" << EOF
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "Abyss Theme"
            }
        ],
        "Id": "com.github.abyss.wallpaper",
        "Name": "Abyss",
        "License": "MIT"
    }
}
EOF
    
    rm -f /tmp/abyss_ascii.txt
    log "Wallpaper generated at $wallpaper_path"
}

create_plasma_theme() {
    log "Creating Plasma desktop theme..."
    
    # metadata.desktop
    cat > "$THEME_DIR/metadata.desktop" << EOF
[Desktop Entry]
Name=$THEME_NAME
Comment=Pure monochrome black theme
X-KDE-PluginInfo-Author=Abyss
X-KDE-PluginInfo-Email=abyss@local
X-KDE-PluginInfo-Name=$THEME_NAME
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=
X-KDE-PluginInfo-Category=Plasma Theme
X-KDE-PluginInfo-License=MIT
X-KDE-PluginInfo-EnabledByDefault=true
X-Plasma-API=5.0
EOF

    # colors
    cat > "$THEME_DIR/colors" << EOF
[Colors:Button]
BackgroundNormal=$COLOR_GRAY2
BackgroundAlternate=$COLOR_GRAY3
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[Colors:Selection]
BackgroundNormal=$COLOR_GRAY3
BackgroundAlternate=$COLOR_GRAY2
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[Colors:Tooltip]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[Colors:View]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[Colors:Window]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[Colors:Complementary]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2

[WM]
activeBackground=$COLOR_BLACK
activeBlend=$COLOR_GRAY3
activeForeground=$COLOR_WHITE
inactiveBackground=$COLOR_BLACK
inactiveBlend=$COLOR_GRAY1
inactiveForeground=$COLOR_GRAY3
EOF

    # Panel background SVG
    mkdir -p "$THEME_DIR/widgets"
    cat > "$THEME_DIR/widgets/panel-background.svg" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="100" height="100">
    <rect width="100" height="100" fill="#000000" opacity="0.95"/>
</svg>
EOF

    log "Plasma theme created"
}

create_color_scheme() {
    log "Creating KDE color scheme..."
    
    cat > "$HOME/.local/share/color-schemes/$THEME_NAME.colors" << EOF
[ColorEffects:Disabled]
Color=$COLOR_GRAY1
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=$COLOR_GRAY2
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=$COLOR_GRAY3
BackgroundNormal=$COLOR_GRAY2
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[Colors:Complementary]
BackgroundAlternate=$COLOR_GRAY1
BackgroundNormal=$COLOR_BLACK
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[Colors:Selection]
BackgroundAlternate=$COLOR_GRAY2
BackgroundNormal=$COLOR_GRAY3
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[Colors:Tooltip]
BackgroundAlternate=$COLOR_GRAY1
BackgroundNormal=$COLOR_BLACK
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[Colors:View]
BackgroundAlternate=$COLOR_GRAY1
BackgroundNormal=$COLOR_BLACK
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[Colors:Window]
BackgroundAlternate=$COLOR_GRAY1
BackgroundNormal=$COLOR_BLACK
DecorationFocus=$COLOR_GRAY3
DecorationHover=$COLOR_GRAY2
ForegroundActive=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundLink=$COLOR_WHITE
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundNormal=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3

[General]
ColorScheme=$THEME_NAME
Name=$THEME_NAME
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=$COLOR_BLACK
activeBlend=$COLOR_GRAY3
activeForeground=$COLOR_WHITE
inactiveBackground=$COLOR_BLACK
inactiveBlend=$COLOR_GRAY1
inactiveForeground=$COLOR_GRAY3
EOF

    log "Color scheme created"
}

create_gtk_themes() {
    log "Creating GTK themes..."
    
    # GTK2
    cat > "$GTK2_DIR/gtk-2.0/gtkrc" << EOF
gtk-color-scheme = "base_color:$COLOR_BLACK\\nbg_color:$COLOR_BLACK\\ntooltip_bg_color:$COLOR_BLACK\\nselected_bg_color:$COLOR_GRAY3\\ntext_color:$COLOR_WHITE\\nfg_color:$COLOR_WHITE\\ntooltip_fg_color:$COLOR_WHITE\\nselected_fg_color:$COLOR_WHITE"

gtk-icon-theme-name = "breeze-dark"
gtk-font-name = "Sans 10"
gtk-cursor-theme-name = "breeze_cursors"
gtk-cursor-theme-size = 24
gtk-toolbar-style = GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size = GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images = 0
gtk-menu-images = 0
gtk-enable-event-sounds = 1
gtk-enable-input-feedback-sounds = 0
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = "hintslight"
gtk-xft-rgba = "rgb"

style "default" {
    bg[NORMAL] = "$COLOR_BLACK"
    bg[PRELIGHT] = "$COLOR_GRAY2"
    bg[SELECTED] = "$COLOR_GRAY3"
    bg[INSENSITIVE] = "$COLOR_GRAY1"
    bg[ACTIVE] = "$COLOR_GRAY2"
    
    fg[NORMAL] = "$COLOR_WHITE"
    fg[PRELIGHT] = "$COLOR_WHITE"
    fg[SELECTED] = "$COLOR_WHITE"
    fg[INSENSITIVE] = "$COLOR_GRAY3"
    fg[ACTIVE] = "$COLOR_WHITE"
    
    text[NORMAL] = "$COLOR_WHITE"
    text[PRELIGHT] = "$COLOR_WHITE"
    text[SELECTED] = "$COLOR_WHITE"
    text[INSENSITIVE] = "$COLOR_GRAY3"
    text[ACTIVE] = "$COLOR_WHITE"
    
    base[NORMAL] = "$COLOR_BLACK"
    base[PRELIGHT] = "$COLOR_GRAY1"
    base[SELECTED] = "$COLOR_GRAY3"
    base[INSENSITIVE] = "$COLOR_GRAY1"
    base[ACTIVE] = "$COLOR_GRAY2"
}

class "*" style "default"
EOF

    # GTK3
    cat > "$GTK3_DIR/gtk-3.0/gtk.css" << EOF
* {
    background-color: $COLOR_BLACK;
    color: $COLOR_WHITE;
    border-color: $COLOR_GRAY3;
}

*:hover {
    background-color: $COLOR_GRAY2;
}

*:selected {
    background-color: $COLOR_GRAY3;
    color: $COLOR_WHITE;
}

*:disabled {
    color: $COLOR_GRAY3;
}

window {
    background-color: $COLOR_BLACK;
}

.view {
    background-color: $COLOR_BLACK;
    color: $COLOR_WHITE;
}

textview text {
    background-color: $COLOR_BLACK;
    color: $COLOR_WHITE;
}

entry {
    background-color: $COLOR_GRAY1;
    color: $COLOR_WHITE;
    border-color: $COLOR_GRAY3;
}

button {
    background-color: $COLOR_GRAY2;
    color: $COLOR_WHITE;
    border-color: $COLOR_GRAY3;
}

button:hover {
    background-color: $COLOR_GRAY3;
}

headerbar {
    background-color: $COLOR_BLACK;
    color: $COLOR_WHITE;
    border-bottom: 1px solid $COLOR_GRAY3;
}

menubar {
    background-color: $COLOR_BLACK;
    color: $COLOR_WHITE;
}

menu {
    background-color: $COLOR_GRAY1;
    color: $COLOR_WHITE;
}

menuitem:hover {
    background-color: $COLOR_GRAY3;
}

scrollbar {
    background-color: $COLOR_GRAY1;
}

scrollbar slider {
    background-color: $COLOR_GRAY3;
}

scrollbar slider:hover {
    background-color: $COLOR_WHITE;
}
EOF

    # GTK4
    cp "$GTK3_DIR/gtk-3.0/gtk.css" "$GTK3_DIR/gtk-4.0/gtk.css"
    
    # GTK settings
    cat > "$HOME/.config/gtk-3.0/settings.ini" << EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=breeze-dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

    cat > "$HOME/.config/gtk-4.0/settings.ini" << EOF
[Settings]
gtk-theme-name=$THEME_NAME
gtk-icon-theme-name=breeze-dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

    log "GTK themes created"
}

create_lookfeel_package() {
    log "Creating Look-and-Feel package..."
    
    # metadata.desktop
    cat > "$LOOKFEEL_DIR/metadata.desktop" << EOF
[Desktop Entry]
Comment=Abyss - Pure Monochrome Theme
Name=$THEME_NAME

[Settings]
accentColorFromWallpaper=false

X-KDE-PluginInfo-Author=Abyss
X-KDE-PluginInfo-Email=abyss@local
X-KDE-PluginInfo-Name=com.github.abyss
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=
X-KDE-PluginInfo-Category=Plasma Look And Feel
X-KDE-PluginInfo-License=MIT
X-KDE-PluginInfo-EnabledByDefault=true
X-KDE-ServiceTypes=Plasma/LookAndFeel
X-Plasma-MainScript=defaults
EOF

    # defaults
    cat > "$LOOKFEEL_DIR/contents/defaults" << EOF
[kdeglobals][KDE]
widgetStyle=Breeze

[kdeglobals][General]
ColorScheme=$THEME_NAME

[kdeglobals][Icons]
Theme=breeze-dark

[plasmarc][Theme]
name=$THEME_NAME

[kcminputrc][Mouse]
cursorTheme=breeze_cursors

[kwinrc][org.kde.kdecoration2]
library=org.kde.breeze
theme=Breeze
EOF

    # Splash screen
    mkdir -p "$SPLASH_DIR/images"
    
    cat > "$SPLASH_DIR/Splash.qml" << 'EOF'
import QtQuick 2.5

Rectangle {
    id: root
    color: "#000000"
    
    property int stage
    
    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    
    Rectangle {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height / 3
        width: 200
        height: 2
        color: "#ffffff"
        
        SequentialAnimation on width {
            id: introAnimation
            running: false
            loops: Animation.Infinite
            
            NumberAnimation {
                from: 200
                to: 400
                duration: 1000
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                from: 400
                to: 200
                duration: 1000
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    Text {
        text: "ABYSS"
        color: "#ffffff"
        font.pointSize: 32
        font.family: "Monospace"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topRect.bottom
        anchors.topMargin: 50
    }
}
EOF

    log "Look-and-Feel package created"
}

create_sddm_theme() {
    log "Creating SDDM theme..."
    
    if [[ ! -d "$SDDM_THEME_DIR" ]]; then
        sudo mkdir -p "$SDDM_THEME_DIR"
    fi
    
    # Main QML
    sudo tee "$SDDM_THEME_DIR/Main.qml" > /dev/null << 'EOF'
import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    width: 1920
    height: 1080
    color: "#000000"

    TextConstants { id: textConstants }

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Clock {
        id: clock
        anchors.margins: 20
        anchors.top: parent.top
        anchors.right: parent.right
        color: "#ffffff"
        font.family: "Monospace"
        font.pointSize: 18
    }

    Rectangle {
        id: loginPanel
        anchors.centerIn: parent
        width: 400
        height: 200
        color: "#0a0a0a"
        border.color: "#111111"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "ABYSS"
                color: "#ffffff"
                font.family: "Monospace"
                font.pointSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: userName
                width: 300
                height: 40
                color: "#ffffff"
                borderColor: "#111111"
                focusColor: "#ffffff"
                hoverColor: "#111111"
                textColor: "#ffffff"
                font.family: "Monospace"
                font.pointSize: 12
                text: userModel.lastUser
                KeyNavigation.backtab: password
                KeyNavigation.tab: password
            }

            PasswordField {
                id: password
                width: 300
                height: 40
                color: "#ffffff"
                borderColor: "#111111"
                focusColor: "#ffffff"
                hoverColor: "#111111"
                textColor: "#ffffff"
                font.family: "Monospace"
                font.pointSize: 12
                KeyNavigation.backtab: userName
                KeyNavigation.tab: loginButton
                
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(userName.text, password.text, session.index)
                        event.accepted = true
                    }
                }
            }

            Button {
                id: loginButton
                text: textConstants.login
                width: 300
                height: 40
                color: "#111111"
                textColor: "#ffffff"
                borderColor: "#ffffff"
                font.family: "Monospace"
                font.pointSize: 12
                onClicked: sddm.login(userName.text, password.text, session.index)
                KeyNavigation.backtab: password
                KeyNavigation.tab: userName
            }
        }
    }

    Component.onCompleted: {
        if (userName.text === "")
            userName.focus = true
        else
            password.focus = true
    }
}
EOF

    # Copy wallpaper to SDDM theme
    sudo cp "$WALLPAPER_DIR/contents/images/1920x1080.png" "$SDDM_THEME_DIR/background.png"
    
    # theme.conf
    sudo tee "$SDDM_THEME_DIR/theme.conf" > /dev/null << EOF
[General]
background=background.png
EOF

    # metadata.desktop
    sudo tee "$SDDM_THEME_DIR/metadata.desktop" > /dev/null << EOF
[SddmGreeterTheme]
Name=$THEME_NAME
Description=Pure monochrome black SDDM theme
Author=Abyss
Copyright=MIT
License=MIT
Type=sddm-theme
Version=1.0
Website=
MainScript=Main.qml
ConfigFile=theme.conf
EOF

    log "SDDM theme created"
}

configure_sddm() {
    log "Configuring SDDM..."
    
    if [[ ! -f /etc/sddm.conf ]]; then
        sudo mkdir -p /etc/sddm.conf.d
        sudo tee /etc/sddm.conf.d/abyss.conf > /dev/null << EOF
[Theme]
Current=$THEME_NAME
EOF
    else
        log "SDDM config exists, manually set theme to '$THEME_NAME' in /etc/sddm.conf"
    fi
}

apply_plasma_settings() {
    log "Applying Plasma settings..."
    
    # Set global theme
    lookandfeeltool -a com.github.abyss 2>/dev/null || true
    
    # Apply color scheme
    kwriteconfig5 --file kdeglobals --group General --key ColorScheme "$THEME_NAME"
    
    # Set plasma theme
    kwriteconfig5 --file plasmarc --group Theme --key name "$THEME_NAME"
    
    # Set wallpaper
    kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc \
        --group Containments --group 1 --group Wallpaper \
        --group org.kde.image --group General \
        --key Image "file://$WALLPAPER_DIR/contents/images/1920x1080.png"
    
    # Dark theme preference
    kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage com.github.abyss
    
    # Window decorations
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
    
    # Icon theme
    kwriteconfig5 --file kdeglobals --group Icons --key Theme breeze-dark
    
    # Cursor theme
    kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme breeze_cursors
    
    log "Plasma settings applied. Restart Plasma for full effect: killall plasmashell && plasmashell &"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    log "Starting $THEME_NAME installation..."
    
    check_root
    install_dependencies
    create_directory_structure
    generate_ascii_wallpaper
    create_plasma_theme
    create_color_scheme
    create_gtk_themes
    create_lookfeel_package
    create_sddm_theme
    configure_sddm
    apply_plasma_settings
    
    log "Installation complete!"
    log ""
    log "Next steps:"
    log "1. Restart Plasma: killall plasmashell && plasmashell &"
    log "2. Or reboot for SDDM theme"
    log "3. System Settings > Appearance > Global Theme > $THEME_NAME"
    log "4. Enjoy the void."
}

main "$@"