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

# Color palette (base monochrome)
COLOR_BLACK="#000000"
COLOR_WHITE="#ffffff"
COLOR_GRAY1="#050505"
COLOR_GRAY2="#0a0a0a"
COLOR_GRAY3="#111111"

# Accent colors (set by variant selection)
COLOR_ACCENT=""
COLOR_ACCENT_DIM=""
COLOR_ACCENT_BRIGHT=""
THEME_VARIANT=""

# ============================================================================
# FUNCTIONS
# ============================================================================

# Set accent colors based on variant
set_variant_colors() {
    local variant="${1:-}"
    
    case "$variant" in
        crimson|red)
            THEME_VARIANT="Crimson"
            COLOR_ACCENT="#8b0000"
            COLOR_ACCENT_DIM="#4a0000"
            COLOR_ACCENT_BRIGHT="#cc0000"
            ;;
        cobalt|blue)
            THEME_VARIANT="Cobalt"
            COLOR_ACCENT="#0a3d62"
            COLOR_ACCENT_DIM="#051d30"
            COLOR_ACCENT_BRIGHT="#1e6fa3"
            ;;
        emerald|green)
            THEME_VARIANT="Emerald"
            COLOR_ACCENT="#0a4a0a"
            COLOR_ACCENT_DIM="#052505"
            COLOR_ACCENT_BRIGHT="#0d6b0d"
            ;;
        ""|pure|mono)
            # Pure monochrome (default) - use gray for accents
            THEME_VARIANT=""
            COLOR_ACCENT="$COLOR_GRAY3"
            COLOR_ACCENT_DIM="$COLOR_GRAY2"
            COLOR_ACCENT_BRIGHT="$COLOR_WHITE"
            ;;
        *)
            error "Unknown variant: $variant. Use: crimson, cobalt, emerald, or leave empty for pure monochrome."
            ;;
    esac
    
    # Update theme name with variant suffix
    if [[ -n "$THEME_VARIANT" ]]; then
        THEME_NAME="Abyss-${THEME_VARIANT}"
    else
        THEME_NAME="Abyss"
    fi
    
    # Update all paths with new theme name
    THEME_DIR="$HOME/.local/share/plasma/desktoptheme/$THEME_NAME"
    LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss${THEME_VARIANT:+.${THEME_VARIANT,,}}"
    SDDM_THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
    GTK2_DIR="$HOME/.themes/$THEME_NAME"
    GTK3_DIR="$HOME/.themes/$THEME_NAME"
    WALLPAPER_DIR="$HOME/.local/share/wallpapers/$THEME_NAME"
    SPLASH_DIR="$LOOKFEEL_DIR/contents/splash"
}

show_help() {
    cat << EOF
ABYSS - KDE Plasma Monochrome Theme Installer

Usage: $0 [OPTIONS]

Options:
    -h, --help              Show this help message
    -v, --variant VARIANT   Install a color accent variant
    
Variants:
    (none)      Pure monochrome (default)
    crimson     Red accent (#8b0000)
    cobalt      Blue accent (#0a3d62)
    emerald     Green accent (#0a4a0a)

Examples:
    $0                      Install pure monochrome Abyss
    $0 --variant crimson    Install Abyss with red accents
    $0 -v cobalt            Install Abyss with blue accents
    $0 -v emerald           Install Abyss with green accents

EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--variant)
                if [[ -n "${2:-}" ]]; then
                    set_variant_colors "$2"
                    shift 2
                else
                    error "Variant name required. Use: crimson, cobalt, or emerald"
                fi
                ;;
            *)
                error "Unknown option: $1. Use --help for usage."
                ;;
        esac
    done
    
    # Set default if no variant specified
    if [[ -z "$COLOR_ACCENT" ]]; then
        set_variant_colors ""
    fi
}

log() {
    echo "[ABYSS] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Convert hex color to RGB decimal format (required by KDE color schemes)
hex_to_rgb() {
    local hex="${1#\#}"
    printf "%d,%d,%d" "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

# Detect Plasma version and set appropriate command names
detect_plasma_version() {
    if command -v kwriteconfig6 &>/dev/null; then
        KWRITECONFIG="kwriteconfig6"
        KREADCONFIG="kreadconfig6"
        PLASMA_VERSION=6
    else
        KWRITECONFIG="kwriteconfig5"
        KREADCONFIG="kreadconfig5"
        PLASMA_VERSION=5
    fi
    
    if command -v lookandfeeltool &>/dev/null; then
        LOOKANDFEELTOOL="lookandfeeltool"
    elif command -v plasma-apply-lookandfeel &>/dev/null; then
        LOOKANDFEELTOOL="plasma-apply-lookandfeel"
    else
        LOOKANDFEELTOOL=""
    fi
    
    log "Detected Plasma version: $PLASMA_VERSION"
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
        "breeze"
        "breeze-gtk"
    )
    
    # Optional GTK2 packages (available in AUR, not in official repos)
    # Install manually if needed: yay -S gtk-engine-murrine
    
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
    
    # Resolutions to generate
    local resolutions=("1920x1080" "2560x1440" "3840x2160" "1366x768")
    
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
    
    # Detect available font (fallback to any monospace if DejaVu not available)
    local font="DejaVu-Sans-Mono"
    if ! convert -list font 2>/dev/null | grep -qi "dejavu"; then
        font="Monospace"
        log "DejaVu font not found, using fallback: $font"
    fi
    
    # Generate wallpapers for each resolution
    for res in "${resolutions[@]}"; do
        local wallpaper_path="$WALLPAPER_DIR/contents/images/${res}.png"
        local width="${res%x*}"
        local height="${res#*x}"
        
        # Scale pointsize based on resolution
        local pointsize=$((12 * width / 1920))
        local offset_x=$((100 * width / 1920))
        local offset_y=$((100 * height / 1080))
        local title_size=$((24 * width / 1920))
        local title_y=$((height - 60 * height / 1080))
        
        log "Generating ${res} wallpaper..."
        
        # Create base wallpaper with ASCII art
        if convert -size "$res" xc:black \
            -font "$font" \
            -pointsize "$pointsize" \
            -fill white \
            -annotate "+${offset_x}+${offset_y}" "@/tmp/abyss_ascii.txt" \
            /tmp/abyss_base.png 2>/dev/null; then
            
            # Add theme name with accent color at bottom
            convert /tmp/abyss_base.png \
                -font "$font" \
                -pointsize "$title_size" \
                -fill "$COLOR_ACCENT_BRIGHT" \
                -gravity south \
                -annotate "+0+30" "$THEME_NAME" \
                "$wallpaper_path" 2>/dev/null || \
                mv /tmp/abyss_base.png "$wallpaper_path"
            
            rm -f /tmp/abyss_base.png
            log "  Created: $wallpaper_path"
        else
            # Fallback: create simple black image with theme name if ASCII rendering fails
            log "  Warning: ASCII rendering failed, creating minimal wallpaper"
            convert -size "$res" xc:black \
                -font "$font" \
                -pointsize "$title_size" \
                -fill "$COLOR_ACCENT_BRIGHT" \
                -gravity center \
                -annotate "+0+0" "$THEME_NAME" \
                "$wallpaper_path" 2>/dev/null || \
                convert -size "$res" xc:black "$wallpaper_path"
        fi
    done
    
    # Create metadata
    local wallpaper_id="com.github.abyss${THEME_VARIANT:+.${THEME_VARIANT,,}}.wallpaper"
    cat > "$WALLPAPER_DIR/metadata.json" << EOF
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "Abyss Theme"
            }
        ],
        "Id": "$wallpaper_id",
        "Name": "$THEME_NAME",
        "License": "MIT"
    }
}
EOF
    
    rm -f /tmp/abyss_ascii.txt
    log "Wallpapers generated for resolutions: ${resolutions[*]}"
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
ForegroundLink=$COLOR_ACCENT_BRIGHT
ForegroundVisited=$COLOR_ACCENT_DIM
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT
DecorationHover=$COLOR_ACCENT_DIM

[Colors:Selection]
BackgroundNormal=$COLOR_ACCENT
BackgroundAlternate=$COLOR_ACCENT_DIM
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_WHITE
ForegroundVisited=$COLOR_GRAY3
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT_BRIGHT
DecorationHover=$COLOR_ACCENT

[Colors:Tooltip]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_ACCENT_BRIGHT
ForegroundVisited=$COLOR_ACCENT_DIM
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT
DecorationHover=$COLOR_ACCENT_DIM

[Colors:View]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_ACCENT_BRIGHT
ForegroundVisited=$COLOR_ACCENT_DIM
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT
DecorationHover=$COLOR_ACCENT_DIM

[Colors:Window]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_ACCENT_BRIGHT
ForegroundVisited=$COLOR_ACCENT_DIM
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT
DecorationHover=$COLOR_ACCENT_DIM

[Colors:Complementary]
BackgroundNormal=$COLOR_BLACK
BackgroundAlternate=$COLOR_GRAY1
ForegroundNormal=$COLOR_WHITE
ForegroundInactive=$COLOR_GRAY3
ForegroundActive=$COLOR_WHITE
ForegroundLink=$COLOR_ACCENT_BRIGHT
ForegroundVisited=$COLOR_ACCENT_DIM
ForegroundNegative=$COLOR_WHITE
ForegroundNeutral=$COLOR_WHITE
ForegroundPositive=$COLOR_WHITE
DecorationFocus=$COLOR_ACCENT
DecorationHover=$COLOR_ACCENT_DIM

[WM]
activeBackground=$COLOR_BLACK
activeBlend=$COLOR_ACCENT
activeForeground=$COLOR_WHITE
inactiveBackground=$COLOR_BLACK
inactiveBlend=$COLOR_GRAY1
inactiveForeground=$COLOR_GRAY3
EOF

    # Panel background SVG
    mkdir -p "$THEME_DIR/widgets"
    cat > "$THEME_DIR/widgets/panel-background.svg" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100">
    <defs>
        <style type="text/css">
            .ColorScheme-Background { fill: #000000; }
        </style>
    </defs>
    <rect id="shadow" width="100" height="100" fill="#000000" opacity="0"/>
    <rect id="center" width="100" height="100" class="ColorScheme-Background" opacity="0.95"/>
</svg>
EOF

    log "Plasma theme created"
}

create_color_scheme() {
    log "Creating KDE color scheme..."
    
    # Convert hex colors to RGB format (required by KDE)
    local RGB_BLACK RGB_WHITE RGB_GRAY1 RGB_GRAY2 RGB_GRAY3
    local RGB_ACCENT RGB_ACCENT_DIM RGB_ACCENT_BRIGHT
    RGB_BLACK=$(hex_to_rgb "$COLOR_BLACK")
    RGB_WHITE=$(hex_to_rgb "$COLOR_WHITE")
    RGB_GRAY1=$(hex_to_rgb "$COLOR_GRAY1")
    RGB_GRAY2=$(hex_to_rgb "$COLOR_GRAY2")
    RGB_GRAY3=$(hex_to_rgb "$COLOR_GRAY3")
    RGB_ACCENT=$(hex_to_rgb "$COLOR_ACCENT")
    RGB_ACCENT_DIM=$(hex_to_rgb "$COLOR_ACCENT_DIM")
    RGB_ACCENT_BRIGHT=$(hex_to_rgb "$COLOR_ACCENT_BRIGHT")
    
    cat > "$HOME/.local/share/color-schemes/$THEME_NAME.colors" << EOF
[ColorEffects:Disabled]
Color=$RGB_GRAY1
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=$RGB_GRAY2
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=$RGB_GRAY3
BackgroundNormal=$RGB_GRAY2
DecorationFocus=$RGB_ACCENT
DecorationHover=$RGB_ACCENT_DIM
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_ACCENT_BRIGHT
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_ACCENT_DIM

[Colors:Complementary]
BackgroundAlternate=$RGB_GRAY1
BackgroundNormal=$RGB_BLACK
DecorationFocus=$RGB_ACCENT
DecorationHover=$RGB_ACCENT_DIM
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_ACCENT_BRIGHT
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_ACCENT_DIM

[Colors:Selection]
BackgroundAlternate=$RGB_ACCENT_DIM
BackgroundNormal=$RGB_ACCENT
DecorationFocus=$RGB_ACCENT_BRIGHT
DecorationHover=$RGB_ACCENT
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_WHITE
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_GRAY3

[Colors:Tooltip]
BackgroundAlternate=$RGB_GRAY1
BackgroundNormal=$RGB_BLACK
DecorationFocus=$RGB_ACCENT
DecorationHover=$RGB_ACCENT_DIM
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_ACCENT_BRIGHT
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_ACCENT_DIM

[Colors:View]
BackgroundAlternate=$RGB_GRAY1
BackgroundNormal=$RGB_BLACK
DecorationFocus=$RGB_ACCENT
DecorationHover=$RGB_ACCENT_DIM
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_ACCENT_BRIGHT
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_GRAY3

[Colors:Window]
BackgroundAlternate=$RGB_GRAY1
BackgroundNormal=$RGB_BLACK
DecorationFocus=$RGB_ACCENT
DecorationHover=$RGB_ACCENT_DIM
ForegroundActive=$RGB_WHITE
ForegroundInactive=$RGB_GRAY3
ForegroundLink=$RGB_ACCENT_BRIGHT
ForegroundNegative=$RGB_WHITE
ForegroundNeutral=$RGB_WHITE
ForegroundNormal=$RGB_WHITE
ForegroundPositive=$RGB_WHITE
ForegroundVisited=$RGB_ACCENT_DIM

[General]
ColorScheme=$THEME_NAME
Name=$THEME_NAME
shadeSortColumn=true

[KDE]
contrast=4

[WM]
activeBackground=$RGB_BLACK
activeBlend=$RGB_ACCENT
activeForeground=$RGB_WHITE
inactiveBackground=$RGB_BLACK
inactiveBlend=$RGB_GRAY1
inactiveForeground=$RGB_GRAY3
EOF

    log "Color scheme created"
}

create_gtk_themes() {
    log "Creating GTK themes..."
    
    # GTK2
    cat > "$GTK2_DIR/gtk-2.0/gtkrc" << EOF
gtk-color-scheme = "base_color:$COLOR_BLACK\\nbg_color:$COLOR_BLACK\\ntooltip_bg_color:$COLOR_BLACK\\nselected_bg_color:$COLOR_ACCENT\\ntext_color:$COLOR_WHITE\\nfg_color:$COLOR_WHITE\\ntooltip_fg_color:$COLOR_WHITE\\nselected_fg_color:$COLOR_WHITE"

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
    bg[PRELIGHT] = "$COLOR_ACCENT_DIM"
    bg[SELECTED] = "$COLOR_ACCENT"
    bg[INSENSITIVE] = "$COLOR_GRAY1"
    bg[ACTIVE] = "$COLOR_ACCENT_DIM"
    
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
    base[SELECTED] = "$COLOR_ACCENT"
    base[INSENSITIVE] = "$COLOR_GRAY1"
    base[ACTIVE] = "$COLOR_ACCENT_DIM"
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
    background-color: $COLOR_ACCENT;
    color: $COLOR_WHITE;
}

*:focus {
    border-color: $COLOR_ACCENT;
    outline-color: $COLOR_ACCENT;
}

*:disabled {
    color: $COLOR_GRAY3;
}

@define-color accent_color $COLOR_ACCENT;
@define-color accent_bg_color $COLOR_ACCENT;
@define-color accent_fg_color $COLOR_WHITE;

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

entry:focus {
    border-color: $COLOR_ACCENT;
}

button {
    background-color: $COLOR_GRAY2;
    color: $COLOR_WHITE;
    border-color: $COLOR_GRAY3;
}

button:hover {
    background-color: $COLOR_ACCENT_DIM;
}

button:checked,
button:active {
    background-color: $COLOR_ACCENT;
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
    background-color: $COLOR_ACCENT;
}

scrollbar {
    background-color: $COLOR_GRAY1;
}

scrollbar slider {
    background-color: $COLOR_GRAY3;
}

scrollbar slider:hover {
    background-color: $COLOR_ACCENT;
}

link, *:link {
    color: $COLOR_ACCENT_BRIGHT;
}

link:visited, *:visited {
    color: $COLOR_ACCENT_DIM;
}

selection {
    background-color: $COLOR_ACCENT;
    color: $COLOR_WHITE;
}

check:checked,
radio:checked {
    background-color: $COLOR_ACCENT;
}

switch:checked slider {
    background-color: $COLOR_ACCENT;
}

progressbar progress {
    background-color: $COLOR_ACCENT;
}

scale highlight {
    background-color: $COLOR_ACCENT;
}
EOF

    # GTK4
    cp "$GTK3_DIR/gtk-3.0/gtk.css" "$GTK3_DIR/gtk-4.0/gtk.css"
    
    # Create GTK config directories if they don't exist
    mkdir -p "$HOME/.config/gtk-3.0"
    mkdir -p "$HOME/.config/gtk-4.0"
    
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

    # Splash screen - using variable expansion for accent colors
    mkdir -p "$SPLASH_DIR/images"
    
    cat > "$SPLASH_DIR/Splash.qml" << EOF
import QtQuick 2.5

Rectangle {
    id: root
    color: "$COLOR_BLACK"
    
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
        height: 3
        color: "$COLOR_ACCENT_BRIGHT"
        
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
        text: "$THEME_NAME"
        color: "$COLOR_WHITE"
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
    
    # Main QML - using variable expansion for accent colors
    sudo tee "$SDDM_THEME_DIR/Main.qml" > /dev/null << EOF
import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "$COLOR_BLACK"

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
        color: "$COLOR_WHITE"
        font.family: "Monospace"
        font.pointSize: 18
    }

    Rectangle {
        id: loginPanel
        anchors.centerIn: parent
        width: 400
        height: 280
        color: "$COLOR_GRAY2"
        border.color: "$COLOR_ACCENT"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 15

            Text {
                text: "$THEME_NAME"
                color: "$COLOR_WHITE"
                font.family: "Monospace"
                font.pointSize: 24
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: userName
                width: 300
                height: 40
                color: "$COLOR_WHITE"
                borderColor: "$COLOR_GRAY3"
                focusColor: "$COLOR_ACCENT_BRIGHT"
                hoverColor: "$COLOR_ACCENT_DIM"
                textColor: "$COLOR_WHITE"
                font.family: "Monospace"
                font.pointSize: 12
                text: userModel.lastUser
                KeyNavigation.backtab: session
                KeyNavigation.tab: password
            }

            PasswordField {
                id: password
                width: 300
                height: 40
                color: "$COLOR_WHITE"
                borderColor: "$COLOR_GRAY3"
                focusColor: "$COLOR_ACCENT_BRIGHT"
                hoverColor: "$COLOR_ACCENT_DIM"
                textColor: "$COLOR_WHITE"
                font.family: "Monospace"
                font.pointSize: 12
                KeyNavigation.backtab: userName
                KeyNavigation.tab: session
                
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(userName.text, password.text, session.index)
                        event.accepted = true
                    }
                }
            }

            ComboBox {
                id: session
                width: 300
                height: 30
                color: "$COLOR_GRAY3"
                borderColor: "$COLOR_GRAY3"
                focusColor: "$COLOR_ACCENT_BRIGHT"
                hoverColor: "$COLOR_ACCENT_DIM"
                textColor: "$COLOR_WHITE"
                font.family: "Monospace"
                font.pointSize: 10
                model: sessionModel
                index: sessionModel.lastIndex
                arrowColor: "$COLOR_WHITE"
                KeyNavigation.backtab: password
                KeyNavigation.tab: loginButton
            }

            Button {
                id: loginButton
                text: textConstants.login
                width: 300
                height: 40
                color: "$COLOR_ACCENT"
                textColor: "$COLOR_WHITE"
                borderColor: "$COLOR_ACCENT_BRIGHT"
                font.family: "Monospace"
                font.pointSize: 12
                onClicked: sddm.login(userName.text, password.text, session.index)
                KeyNavigation.backtab: session
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

    # Copy wallpaper to SDDM theme (with existence check)
    local wallpaper_source="$WALLPAPER_DIR/contents/images/1920x1080.png"
    if [[ -f "$wallpaper_source" ]]; then
        sudo cp "$wallpaper_source" "$SDDM_THEME_DIR/background.png"
    else
        log "Warning: Wallpaper not found at $wallpaper_source, creating solid black background"
        # Create a simple black background as fallback
        sudo convert -size 1920x1080 xc:black "$SDDM_THEME_DIR/background.png"
    fi
    
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
    
    # Set global theme using detected tool
    if [[ -n "$LOOKANDFEELTOOL" ]]; then
        if [[ "$LOOKANDFEELTOOL" == "plasma-apply-lookandfeel" ]]; then
            $LOOKANDFEELTOOL -a com.github.abyss 2>/dev/null || true
        else
            $LOOKANDFEELTOOL -a com.github.abyss 2>/dev/null || true
        fi
    fi
    
    # Apply color scheme
    $KWRITECONFIG --file kdeglobals --group General --key ColorScheme "$THEME_NAME"
    
    # Set plasma theme
    $KWRITECONFIG --file plasmarc --group Theme --key name "$THEME_NAME"
    
    # Set wallpaper (use first available resolution)
    local wallpaper_file="$WALLPAPER_DIR/contents/images/1920x1080.png"
    if [[ -f "$wallpaper_file" ]]; then
        $KWRITECONFIG --file plasma-org.kde.plasma.desktop-appletsrc \
            --group Containments --group 1 --group Wallpaper \
            --group org.kde.image --group General \
            --key Image "file://$wallpaper_file"
    fi
    
    # Dark theme preference
    $KWRITECONFIG --file kdeglobals --group KDE --key LookAndFeelPackage com.github.abyss
    
    # Window decorations
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
    
    # Icon theme
    $KWRITECONFIG --file kdeglobals --group Icons --key Theme breeze-dark
    
    # Cursor theme
    $KWRITECONFIG --file kcminputrc --group Mouse --key cursorTheme breeze_cursors
    
    log "Plasma settings applied. Restart Plasma for full effect: killall plasmashell && plasmashell &"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    parse_arguments "$@"
    
    log "Starting $THEME_NAME installation..."
    if [[ -n "$THEME_VARIANT" ]]; then
        log "Variant: $THEME_VARIANT (accent: $COLOR_ACCENT)"
    else
        log "Variant: Pure Monochrome"
    fi
    
    check_root
    detect_plasma_version
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