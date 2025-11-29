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
KVANTUM_DIR="$HOME/.config/Kvantum/$THEME_NAME"
AURORAE_DIR="$HOME/.local/share/aurorae/themes/$THEME_NAME"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"

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
    KVANTUM_DIR="$HOME/.config/Kvantum/$THEME_NAME"
    AURORAE_DIR="$HOME/.local/share/aurorae/themes/$THEME_NAME"
    PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"
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
        "kvantum"
        "bc"
    )
    
    # Optional packages (plymouth may not be in official repos)
    local optional_packages=(
        "plymouth"
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
    
    # Check optional packages
    for pkg in "${optional_packages[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            log "Optional package not installed: $pkg (Plymouth boot theme may not work)"
        fi
    done
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
    mkdir -p "$HOME/.config/Kvantum"
    mkdir -p "$KVANTUM_DIR"
    mkdir -p "$AURORAE_DIR"
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

create_kvantum_theme() {
    log "Creating Kvantum theme..."
    
    mkdir -p "$KVANTUM_DIR"
    
    # Create the Kvantum SVG file with all UI elements
    cat > "$KVANTUM_DIR/$THEME_NAME.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="640" viewBox="0 0 640 640">
  <defs>
    <linearGradient id="button-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:$COLOR_GRAY2"/>
      <stop offset="100%" style="stop-color:$COLOR_GRAY1"/>
    </linearGradient>
    <linearGradient id="button-hover-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:$COLOR_ACCENT_DIM"/>
      <stop offset="100%" style="stop-color:$COLOR_ACCENT"/>
    </linearGradient>
    <linearGradient id="button-pressed-gradient" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:$COLOR_ACCENT"/>
      <stop offset="100%" style="stop-color:$COLOR_ACCENT_DIM"/>
    </linearGradient>
  </defs>
  
  <!-- PushButton normal -->
  <g id="button-normal">
    <rect x="0" y="0" width="100" height="30" rx="2" fill="url(#button-gradient)" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- PushButton hover -->
  <g id="button-hover">
    <rect x="0" y="40" width="100" height="30" rx="2" fill="url(#button-hover-gradient)" stroke="$COLOR_ACCENT" stroke-width="1"/>
  </g>
  
  <!-- PushButton pressed -->
  <g id="button-pressed">
    <rect x="0" y="80" width="100" height="30" rx="2" fill="url(#button-pressed-gradient)" stroke="$COLOR_ACCENT_BRIGHT" stroke-width="1"/>
  </g>
  
  <!-- PushButton disabled -->
  <g id="button-disabled">
    <rect x="0" y="120" width="100" height="30" rx="2" fill="$COLOR_GRAY1" stroke="$COLOR_GRAY2" stroke-width="1" opacity="0.5"/>
  </g>
  
  <!-- LineEdit normal -->
  <g id="lineedit-normal">
    <rect x="110" y="0" width="100" height="26" rx="2" fill="$COLOR_BLACK" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- LineEdit focused -->
  <g id="lineedit-focused">
    <rect x="110" y="30" width="100" height="26" rx="2" fill="$COLOR_BLACK" stroke="$COLOR_ACCENT" stroke-width="2"/>
  </g>
  
  <!-- ComboBox normal -->
  <g id="combobox-normal">
    <rect x="220" y="0" width="100" height="26" rx="2" fill="$COLOR_GRAY2" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- ComboBox hover -->
  <g id="combobox-hover">
    <rect x="220" y="30" width="100" height="26" rx="2" fill="$COLOR_GRAY2" stroke="$COLOR_ACCENT" stroke-width="1"/>
  </g>
  
  <!-- Scrollbar groove -->
  <g id="scrollbar-groove">
    <rect x="330" y="0" width="12" height="100" rx="6" fill="$COLOR_GRAY1"/>
  </g>
  
  <!-- Scrollbar slider -->
  <g id="scrollbar-slider">
    <rect x="350" y="0" width="12" height="40" rx="6" fill="$COLOR_GRAY3"/>
  </g>
  
  <!-- Scrollbar slider hover -->
  <g id="scrollbar-slider-hover">
    <rect x="370" y="0" width="12" height="40" rx="6" fill="$COLOR_ACCENT"/>
  </g>
  
  <!-- Tab normal -->
  <g id="tab-normal">
    <rect x="0" y="160" width="80" height="30" rx="2" fill="$COLOR_GRAY1" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Tab active -->
  <g id="tab-active">
    <rect x="90" y="160" width="80" height="30" rx="2" fill="$COLOR_BLACK" stroke="$COLOR_ACCENT" stroke-width="1"/>
    <rect x="90" y="186" width="80" height="4" fill="$COLOR_ACCENT"/>
  </g>
  
  <!-- Tab hover -->
  <g id="tab-hover">
    <rect x="180" y="160" width="80" height="30" rx="2" fill="$COLOR_GRAY2" stroke="$COLOR_ACCENT_DIM" stroke-width="1"/>
  </g>
  
  <!-- Checkbox unchecked -->
  <g id="checkbox-unchecked">
    <rect x="0" y="200" width="18" height="18" rx="2" fill="$COLOR_BLACK" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Checkbox checked -->
  <g id="checkbox-checked">
    <rect x="25" y="200" width="18" height="18" rx="2" fill="$COLOR_ACCENT" stroke="$COLOR_ACCENT_BRIGHT" stroke-width="1"/>
    <path d="M28,209 L32,213 L40,205" stroke="$COLOR_WHITE" stroke-width="2" fill="none"/>
  </g>
  
  <!-- Radio unchecked -->
  <g id="radio-unchecked">
    <circle cx="59" cy="209" r="9" fill="$COLOR_BLACK" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Radio checked -->
  <g id="radio-checked">
    <circle cx="84" cy="209" r="9" fill="$COLOR_BLACK" stroke="$COLOR_ACCENT" stroke-width="1"/>
    <circle cx="84" cy="209" r="5" fill="$COLOR_ACCENT"/>
  </g>
  
  <!-- Progressbar groove -->
  <g id="progressbar-groove">
    <rect x="0" y="230" width="200" height="8" rx="4" fill="$COLOR_GRAY1"/>
  </g>
  
  <!-- Progressbar contents -->
  <g id="progressbar-contents">
    <rect x="0" y="245" width="100" height="8" rx="4" fill="$COLOR_ACCENT"/>
  </g>
  
  <!-- Slider groove -->
  <g id="slider-groove">
    <rect x="0" y="260" width="200" height="4" rx="2" fill="$COLOR_GRAY1"/>
  </g>
  
  <!-- Slider handle -->
  <g id="slider-handle">
    <circle cx="100" cy="275" r="8" fill="$COLOR_WHITE" stroke="$COLOR_ACCENT" stroke-width="2"/>
  </g>
  
  <!-- Menu background -->
  <g id="menu-background">
    <rect x="400" y="0" width="150" height="150" rx="2" fill="$COLOR_GRAY1" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Menu item hover -->
  <g id="menu-item-hover">
    <rect x="400" y="160" width="150" height="28" fill="$COLOR_ACCENT"/>
  </g>
  
  <!-- Tooltip background -->
  <g id="tooltip-background">
    <rect x="400" y="200" width="150" height="40" rx="2" fill="$COLOR_BLACK" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Frame/GroupBox -->
  <g id="frame">
    <rect x="0" y="300" width="150" height="100" rx="2" fill="none" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Header section -->
  <g id="header-section">
    <rect x="160" y="300" width="150" height="30" fill="$COLOR_GRAY2" stroke="$COLOR_GRAY3" stroke-width="1"/>
  </g>
  
  <!-- Spin box buttons -->
  <g id="spinbox-up">
    <rect x="320" y="300" width="20" height="15" fill="$COLOR_GRAY2" stroke="$COLOR_GRAY3" stroke-width="1"/>
    <path d="M325,312 L330,305 L335,312" fill="$COLOR_WHITE"/>
  </g>
  
  <g id="spinbox-down">
    <rect x="320" y="320" width="20" height="15" fill="$COLOR_GRAY2" stroke="$COLOR_GRAY3" stroke-width="1"/>
    <path d="M325,323 L330,330 L335,323" fill="$COLOR_WHITE"/>
  </g>
</svg>
EOF

    # Create the Kvantum configuration file
    cat > "$KVANTUM_DIR/$THEME_NAME.kvconfig" << EOF
[%General]
author=Abyss Theme
comment=Pure monochrome black theme for Qt applications
x11drag=menubar_and_primary_toolbar
alt_mnemonic=true
left_tabs=false
attach_active_tab=true
mirror_doc_tabs=true
group_toolbar_buttons=false
toolbar_item_spacing=0
toolbar_interior_spacing=2
spread_progressbar=true
composite=true
menu_shadow_depth=7
submenu_overlap=0
splitter_width=1
scroll_width=12
scroll_arrows=false
scroll_min_extent=60
slider_width=4
slider_handle_width=18
slider_handle_length=18
tickless_slider_handle_size=18
center_toolbar_handle=true
check_size=18
textless_progressbar=false
progressbar_thickness=8
menubar_mouse_tracking=true
toolbutton_style=0
double_click=false
translucent_windows=false
blurring=false
popup_blurring=false
vertical_spin_indicators=false
spin_button_width=20
fill_rubberband=false
merge_menubar_with_toolbar=false
small_icon_size=16
large_icon_size=32
button_icon_size=16
toolbar_icon_size=22
combo_as_lineedit=true
animate_states=true
button_contents_shift=false
combo_menu=true
hide_combo_checkboxes=false
combo_focus_rect=true
scrollbar_in_view=false
transient_scrollbar=false
transient_groove=false
scrollable_menu=true
tree_branch_line=true
no_window_pattern=true
opaque=kaffeine,kmplayer,subtitlecomposer,kdenlive,vlc,smplayer,smplayer2,avidemux,avidemux2_qt4,avidemux3_qt4,avidemux3_qt5,kamoso,QtCreator,VirtualBox,VirtualBoxVM,trojita,dragon,digikam,lyx,Lightworks,Lightworks.bin,obs,obs-studio

[GeneralColors]
window.color=$COLOR_BLACK
base.color=$COLOR_BLACK
alt.base.color=$COLOR_GRAY1
button.color=$COLOR_GRAY2
light.color=$COLOR_GRAY3
mid.light.color=$COLOR_GRAY2
dark.color=$COLOR_BLACK
mid.color=$COLOR_GRAY1
highlight.color=$COLOR_ACCENT
inactive.highlight.color=$COLOR_ACCENT_DIM
text.color=$COLOR_WHITE
window.text.color=$COLOR_WHITE
button.text.color=$COLOR_WHITE
disabled.text.color=$COLOR_GRAY3
tooltip.text.color=$COLOR_WHITE
highlight.text.color=$COLOR_WHITE
link.color=$COLOR_ACCENT_BRIGHT
link.visited.color=$COLOR_ACCENT_DIM
progress.indicator.text.color=$COLOR_WHITE
progress.inactive.indicator.text.color=$COLOR_WHITE

[Hacks]
transparent_dolphin_view=false
transparent_pcmanfm_sidepane=false
transparent_pcmanfm_view=false
blur_translucent=false
transparent_ktitle_label=true
transparent_menutitle=true
respect_darkness=true
kcapacitybar_as_progressbar=true
force_size_grip=true
iconless_pushbutton=false
iconless_menu=false
disabled_icon_opacity=70
lxqtmainmenu_iconsize=22
normal_default_pushbutton=true
single_top_toolbar=false
middle_click_scroll=false
no_selection_tint=false
transparent_arrow_button=true
tint_on_mouseover=0
scroll_jump_workaround=false
centered_forms=false
kinetic_scrolling=false
noninteger_translucency=false

[PanelButtonCommand]
frame=true
frame.element=button
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
interior=true
interior.element=button
indicator.size=9
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.press.color=$COLOR_WHITE
text.toggle.color=$COLOR_WHITE
text.shadow=0
text.margin=1
text.iconspacing=4
indicator.element=arrow
min_width=+0.4font
min_height=+0.4font

[PanelButtonTool]
inherits=PanelButtonCommand

[Dock]
inherits=PanelButtonCommand
interior.element=toolbar
frame.element=toolbar
frame.top=0
frame.bottom=0
frame.left=0
frame.right=0

[DockTitle]
inherits=PanelButtonCommand
frame=false
interior=false
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT
text.bold=true

[IndicatorSpinBox]
inherits=PanelButtonCommand
indicator.element=spin
indicator.size=9
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2

[RadioButton]
inherits=PanelButtonCommand
frame=false
interior.element=radio
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT

[CheckBox]
inherits=PanelButtonCommand
frame=false
interior.element=checkbox
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT

[Focus]
inherits=PanelButtonCommand
frame=true
frame.element=focus
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
frame.patternsize=20

[GenericFrame]
inherits=PanelButtonCommand
frame=true
interior=false
frame.element=common
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1

[LineEdit]
inherits=PanelButtonCommand
frame.element=lineedit
interior.element=lineedit
text.margin.top=2
text.margin.bottom=2
text.margin.left=4
text.margin.right=4

[DropDownButton]
inherits=PanelButtonCommand
indicator.element=arrow-down
indicator.size=9

[IndicatorArrow]
inherits=PanelButtonCommand
indicator.element=arrow
indicator.size=9

[ToolboxTab]
inherits=PanelButtonCommand
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT
text.press.color=$COLOR_WHITE

[Tab]
inherits=PanelButtonCommand
frame.element=tab
interior.element=tab
frame.top=2
frame.bottom=3
frame.left=3
frame.right=3
text.normal.color=$COLOR_GRAY3
text.focus.color=$COLOR_WHITE
text.toggle.color=$COLOR_WHITE
indicator.element=tab
indicator.size=12

[TabFrame]
inherits=PanelButtonCommand
frame=true
frame.element=tabframe
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
interior=true
interior.element=tabframe

[TreeExpander]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.size=9
indicator.element=tree

[HeaderSection]
inherits=PanelButtonCommand
frame.element=header
interior.element=header
frame.top=1
frame.bottom=1
frame.left=1
frame.right=1
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT
text.press.color=$COLOR_WHITE

[SizeGrip]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.element=resize
indicator.size=13

[Toolbar]
inherits=PanelButtonCommand
frame=false
frame.element=toolbar
interior=true
interior.element=toolbar
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT

[Slider]
inherits=PanelButtonCommand
frame=false
interior.element=slider
frame.element=slider
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3

[SliderCursor]
inherits=PanelButtonCommand
frame=false
interior.element=slidercursor

[Progressbar]
inherits=PanelButtonCommand
frame.element=progress
interior.element=progress
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.press.color=$COLOR_WHITE
text.toggle.color=$COLOR_WHITE
text.bold=true

[ProgressbarContents]
inherits=PanelButtonCommand
frame=false
interior.element=progress-pattern

[ItemView]
inherits=PanelButtonCommand
frame.element=itemview
interior.element=itemview
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.press.color=$COLOR_WHITE
text.toggle.color=$COLOR_WHITE

[Splitter]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.size=32

[Scrollbar]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.element=arrow
indicator.size=9

[ScrollbarSlider]
inherits=PanelButtonCommand
frame=false
frame.element=scrollbarslider
interior=true
interior.element=scrollbarslider
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4

[ScrollbarGroove]
inherits=PanelButtonCommand
frame=false
interior=true
interior.element=scrollbargroove

[Menu]
inherits=PanelButtonCommand
frame.element=menu
interior.element=menu
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
text.normal.color=$COLOR_WHITE

[MenuItem]
inherits=PanelButtonCommand
frame=true
frame.element=menuitem
interior.element=menuitem
frame.top=2
frame.bottom=2
frame.left=5
frame.right=5
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.margin.top=1
text.margin.bottom=1
text.margin.left=3
text.margin.right=3

[MenuBar]
inherits=PanelButtonCommand
frame=false
interior=true
interior.element=menubar
text.normal.color=$COLOR_WHITE

[MenuBarItem]
inherits=PanelButtonCommand
frame=true
frame.element=menubaritem
interior.element=menubaritem
frame.top=2
frame.bottom=2
frame.left=4
frame.right=4
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.margin.top=1
text.margin.bottom=1

[TitleBar]
inherits=PanelButtonCommand
frame=false
interior=false
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_WHITE
text.bold=true
text.italic=false

[ComboBox]
inherits=PanelButtonCommand
frame.element=combo
interior.element=combo
indicator.element=arrow-down
indicator.size=9

[GroupBox]
inherits=GenericFrame
frame=true
frame.element=group
text.shadow=0
text.margin=0
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
text.normal.color=$COLOR_WHITE
text.focus.color=$COLOR_ACCENT_BRIGHT
text.bold=true

[TabBarFrame]
inherits=GenericFrame
frame=true
frame.element=tabbarframe
interior=false

[ToolTip]
inherits=GenericFrame
frame.element=tooltip
interior.element=tooltip
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
text.normal.color=$COLOR_WHITE

[StatusBar]
inherits=GenericFrame
frame=false
interior=false

[Window]
interior=true
interior.element=window
frame.top=0
frame.bottom=0
frame.left=0
frame.right=0
EOF

    # Create kvantum.kvconfig to set this as the active theme
    mkdir -p "$HOME/.config/Kvantum"
    cat > "$HOME/.config/Kvantum/kvantum.kvconfig" << EOF
[General]
theme=$THEME_NAME
EOF

    log "Kvantum theme created"
}

create_aurorae_theme() {
    log "Creating Aurorae window decoration theme..."
    
    mkdir -p "$AURORAE_DIR"
    
    # Create the main decoration SVG
    cat > "$AURORAE_DIR/decoration.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="500" height="150" viewBox="0 0 500 150">
  <!-- Window decoration elements for Aurorae -->
  
  <!-- Active window title bar -->
  <g id="decoration-top">
    <rect id="decoration-top-center" x="50" y="0" width="400" height="28" fill="$COLOR_BLACK"/>
    <rect id="decoration-top-left" x="0" y="0" width="50" height="28" fill="$COLOR_BLACK"/>
    <rect id="decoration-top-right" x="450" y="0" width="50" height="28" fill="$COLOR_BLACK"/>
  </g>
  
  <!-- Active window borders -->
  <g id="decoration-border">
    <rect id="decoration-left" x="0" y="28" width="1" height="100" fill="$COLOR_GRAY3"/>
    <rect id="decoration-right" x="499" y="28" width="1" height="100" fill="$COLOR_GRAY3"/>
    <rect id="decoration-bottom" x="0" y="128" width="500" height="1" fill="$COLOR_GRAY3"/>
  </g>
  
  <!-- Inactive window title bar -->
  <g id="decoration-inactive-top">
    <rect id="decoration-inactive-top-center" x="50" y="0" width="400" height="28" fill="$COLOR_BLACK"/>
    <rect id="decoration-inactive-top-left" x="0" y="0" width="50" height="28" fill="$COLOR_BLACK"/>
    <rect id="decoration-inactive-top-right" x="450" y="0" width="50" height="28" fill="$COLOR_BLACK"/>
  </g>
  
  <!-- Inactive window borders -->
  <g id="decoration-inactive-border">
    <rect id="decoration-inactive-left" x="0" y="28" width="1" height="100" fill="$COLOR_GRAY2"/>
    <rect id="decoration-inactive-right" x="499" y="28" width="1" height="100" fill="$COLOR_GRAY2"/>
    <rect id="decoration-inactive-bottom" x="0" y="128" width="500" height="1" fill="$COLOR_GRAY2"/>
  </g>
</svg>
EOF

    # Create close button SVG
    cat > "$AURORAE_DIR/close.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Close button states -->
  
  <!-- Normal state -->
  <g id="close">
    <circle cx="25" cy="25" r="10" fill="transparent"/>
    <path d="M18,18 L32,32 M32,18 L18,32" stroke="$COLOR_GRAY3" stroke-width="2" stroke-linecap="round"/>
  </g>
  
  <!-- Hover state -->
  <g id="close-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <path d="M18,18 L32,32 M32,18 L18,32" stroke="$COLOR_WHITE" stroke-width="2" stroke-linecap="round"/>
  </g>
  
  <!-- Pressed state -->
  <g id="close-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_BRIGHT"/>
    <path d="M18,18 L32,32 M32,18 L18,32" stroke="$COLOR_WHITE" stroke-width="2" stroke-linecap="round"/>
  </g>
  
  <!-- Inactive state -->
  <g id="close-inactive">
    <circle cx="25" cy="25" r="10" fill="transparent"/>
    <path d="M18,18 L32,32 M32,18 L18,32" stroke="$COLOR_GRAY2" stroke-width="2" stroke-linecap="round"/>
  </g>
</svg>
EOF

    # Create maximize button SVG
    cat > "$AURORAE_DIR/maximize.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Maximize button states -->
  
  <!-- Normal state -->
  <g id="maximize">
    <rect x="17" y="17" width="16" height="16" fill="none" stroke="$COLOR_GRAY3" stroke-width="2"/>
  </g>
  
  <!-- Hover state -->
  <g id="maximize-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <rect x="17" y="17" width="16" height="16" fill="none" stroke="$COLOR_WHITE" stroke-width="2"/>
  </g>
  
  <!-- Pressed state -->
  <g id="maximize-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <rect x="17" y="17" width="16" height="16" fill="none" stroke="$COLOR_WHITE" stroke-width="2"/>
  </g>
  
  <!-- Inactive state -->
  <g id="maximize-inactive">
    <rect x="17" y="17" width="16" height="16" fill="none" stroke="$COLOR_GRAY2" stroke-width="2"/>
  </g>
</svg>
EOF

    # Create restore button SVG (for maximized windows)
    cat > "$AURORAE_DIR/restore.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Restore button states -->
  
  <!-- Normal state -->
  <g id="restore">
    <rect x="20" y="14" width="12" height="12" fill="none" stroke="$COLOR_GRAY3" stroke-width="2"/>
    <rect x="18" y="18" width="12" height="12" fill="$COLOR_BLACK" stroke="$COLOR_GRAY3" stroke-width="2"/>
  </g>
  
  <!-- Hover state -->
  <g id="restore-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <rect x="20" y="14" width="12" height="12" fill="none" stroke="$COLOR_WHITE" stroke-width="2"/>
    <rect x="18" y="18" width="12" height="12" fill="$COLOR_ACCENT_DIM" stroke="$COLOR_WHITE" stroke-width="2"/>
  </g>
  
  <!-- Pressed state -->
  <g id="restore-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <rect x="20" y="14" width="12" height="12" fill="none" stroke="$COLOR_WHITE" stroke-width="2"/>
    <rect x="18" y="18" width="12" height="12" fill="$COLOR_ACCENT" stroke="$COLOR_WHITE" stroke-width="2"/>
  </g>
  
  <!-- Inactive state -->
  <g id="restore-inactive">
    <rect x="20" y="14" width="12" height="12" fill="none" stroke="$COLOR_GRAY2" stroke-width="2"/>
    <rect x="18" y="18" width="12" height="12" fill="$COLOR_BLACK" stroke="$COLOR_GRAY2" stroke-width="2"/>
  </g>
</svg>
EOF

    # Create minimize button SVG
    cat > "$AURORAE_DIR/minimize.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Minimize button states -->
  
  <!-- Normal state -->
  <g id="minimize">
    <rect x="17" y="24" width="16" height="2" fill="$COLOR_GRAY3"/>
  </g>
  
  <!-- Hover state -->
  <g id="minimize-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <rect x="17" y="24" width="16" height="2" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Pressed state -->
  <g id="minimize-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <rect x="17" y="24" width="16" height="2" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Inactive state -->
  <g id="minimize-inactive">
    <rect x="17" y="24" width="16" height="2" fill="$COLOR_GRAY2"/>
  </g>
</svg>
EOF

    # Create all-desktops (pin) button SVG
    cat > "$AURORAE_DIR/alldesktops.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- All Desktops button states -->
  
  <!-- Normal state -->
  <g id="alldesktops">
    <circle cx="25" cy="25" r="4" fill="$COLOR_GRAY3"/>
  </g>
  
  <!-- Hover state -->
  <g id="alldesktops-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <circle cx="25" cy="25" r="4" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Pressed state -->
  <g id="alldesktops-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <circle cx="25" cy="25" r="5" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Inactive state -->
  <g id="alldesktops-inactive">
    <circle cx="25" cy="25" r="4" fill="$COLOR_GRAY2"/>
  </g>
</svg>
EOF

    # Create keep-above button SVG
    cat > "$AURORAE_DIR/keepabove.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Keep Above button states -->
  
  <!-- Normal state -->
  <g id="keepabove">
    <path d="M17,28 L25,18 L33,28" stroke="$COLOR_GRAY3" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Hover state -->
  <g id="keepabove-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <path d="M17,28 L25,18 L33,28" stroke="$COLOR_WHITE" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Pressed state -->
  <g id="keepabove-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <path d="M17,28 L25,18 L33,28" stroke="$COLOR_WHITE" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Inactive state -->
  <g id="keepabove-inactive">
    <path d="M17,28 L25,18 L33,28" stroke="$COLOR_GRAY2" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
</svg>
EOF

    # Create keep-below button SVG
    cat > "$AURORAE_DIR/keepbelow.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Keep Below button states -->
  
  <!-- Normal state -->
  <g id="keepbelow">
    <path d="M17,22 L25,32 L33,22" stroke="$COLOR_GRAY3" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Hover state -->
  <g id="keepbelow-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <path d="M17,22 L25,32 L33,22" stroke="$COLOR_WHITE" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Pressed state -->
  <g id="keepbelow-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <path d="M17,22 L25,32 L33,22" stroke="$COLOR_WHITE" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
  
  <!-- Inactive state -->
  <g id="keepbelow-inactive">
    <path d="M17,22 L25,32 L33,22" stroke="$COLOR_GRAY2" stroke-width="2" fill="none" stroke-linecap="round"/>
  </g>
</svg>
EOF

    # Create shade button SVG
    cat > "$AURORAE_DIR/shade.svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="50" height="50" viewBox="0 0 50 50">
  <!-- Shade button states -->
  
  <!-- Normal state -->
  <g id="shade">
    <rect x="17" y="20" width="16" height="2" fill="$COLOR_GRAY3"/>
    <rect x="17" y="25" width="16" height="2" fill="$COLOR_GRAY3"/>
    <rect x="17" y="30" width="16" height="2" fill="$COLOR_GRAY3"/>
  </g>
  
  <!-- Hover state -->
  <g id="shade-hover">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT_DIM"/>
    <rect x="17" y="20" width="16" height="2" fill="$COLOR_WHITE"/>
    <rect x="17" y="25" width="16" height="2" fill="$COLOR_WHITE"/>
    <rect x="17" y="30" width="16" height="2" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Pressed state -->
  <g id="shade-pressed">
    <circle cx="25" cy="25" r="12" fill="$COLOR_ACCENT"/>
    <rect x="17" y="20" width="16" height="2" fill="$COLOR_WHITE"/>
    <rect x="17" y="25" width="16" height="2" fill="$COLOR_WHITE"/>
    <rect x="17" y="30" width="16" height="2" fill="$COLOR_WHITE"/>
  </g>
  
  <!-- Inactive state -->
  <g id="shade-inactive">
    <rect x="17" y="20" width="16" height="2" fill="$COLOR_GRAY2"/>
    <rect x="17" y="25" width="16" height="2" fill="$COLOR_GRAY2"/>
    <rect x="17" y="30" width="16" height="2" fill="$COLOR_GRAY2"/>
  </g>
</svg>
EOF

    # Create the Aurorae configuration file
    cat > "$AURORAE_DIR/${THEME_NAME}rc" << EOF
[General]
ActiveTextColor=$COLOR_WHITE
Animation=0
ButtonHeight=22
ButtonMarginTop=4
ButtonSpacing=4
ButtonWidth=22
ExplicitButtonSpacer=4
InactiveTextColor=$COLOR_GRAY3
PaddingBottom=1
PaddingLeft=1
PaddingRight=1
PaddingTop=4
TitleAlignment=Center
TitleEdgeBottom=0
TitleEdgeBottomMaximized=0
TitleEdgeLeft=4
TitleEdgeLeftMaximized=0
TitleEdgeRight=4
TitleEdgeRightMaximized=0
TitleEdgeTop=4
TitleEdgeTopMaximized=0
TitleHeight=24
TitleHeightMaximized=24
TitleBorderLeft=0
TitleBorderRight=0
EOF

    # Create metadata.desktop
    cat > "$AURORAE_DIR/metadata.desktop" << EOF
[Desktop Entry]
Name=$THEME_NAME
Comment=Pure monochrome window decoration theme
X-KDE-PluginInfo-Author=Abyss Theme
X-KDE-PluginInfo-Email=abyss@local
X-KDE-PluginInfo-Name=$THEME_NAME
X-KDE-PluginInfo-Version=1.0
X-KDE-PluginInfo-Website=
X-KDE-PluginInfo-License=MIT
EOF

    log "Aurorae window decoration theme created"
}

create_plymouth_theme() {
    log "Creating Plymouth boot theme..."
    
    # Plymouth requires sudo for installation
    if [[ ! -d "$PLYMOUTH_THEME_DIR" ]]; then
        sudo mkdir -p "$PLYMOUTH_THEME_DIR"
    fi
    
    # Create the main Plymouth theme descriptor
    sudo tee "$PLYMOUTH_THEME_DIR/$THEME_NAME.plymouth" > /dev/null << EOF
[Plymouth Theme]
Name=$THEME_NAME
Description=Pure monochrome boot splash theme
ModuleName=script

[script]
ImageDir=$PLYMOUTH_THEME_DIR
ScriptFile=$PLYMOUTH_THEME_DIR/$THEME_NAME.script
EOF

    # Create the Plymouth script
    # Using hex colors without # for Plymouth script compatibility
    local accent_hex="${COLOR_ACCENT#\#}"
    local accent_bright_hex="${COLOR_ACCENT_BRIGHT#\#}"
    local white_hex="${COLOR_WHITE#\#}"
    local gray3_hex="${COLOR_GRAY3#\#}"
    
    sudo tee "$PLYMOUTH_THEME_DIR/$THEME_NAME.script" > /dev/null << 'SCRIPT_EOF'
# Abyss Plymouth Theme Script
# Pure monochrome boot splash

# Window and screen setup
Window.SetBackgroundTopColor(0, 0, 0);
Window.SetBackgroundBottomColor(0, 0, 0);

# Get screen dimensions
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();
screen_x = Window.GetX();
screen_y = Window.GetY();

# Theme name text
theme_text = "$THEME_NAME";

# Progress bar dimensions
progress_bar_width = 300;
progress_bar_height = 4;
progress_bar_x = screen_x + (screen_width / 2) - (progress_bar_width / 2);
progress_bar_y = screen_y + (screen_height / 2);

# Create progress bar background (dark gray)
progress_bg = Image.Text("", 0.07, 0.07, 0.07);
for (i = 0; i < progress_bar_width; i++) {
    progress_bg_sprite[i] = Sprite();
    progress_bg_sprite[i].SetImage(Image.Text("|", 0.07, 0.07, 0.07));
    progress_bg_sprite[i].SetPosition(progress_bar_x + i, progress_bar_y, 1);
}

# Progress indicator sprites array
progress_sprites = [];

# Create theme name text
SCRIPT_EOF

    # Now append the color-specific parts using actual variables
    local r_accent=$((16#${accent_hex:0:2}))
    local g_accent=$((16#${accent_hex:2:2}))
    local b_accent=$((16#${accent_hex:4:2}))
    local r_accent_norm=$(echo "scale=2; $r_accent/255" | bc)
    local g_accent_norm=$(echo "scale=2; $g_accent/255" | bc)
    local b_accent_norm=$(echo "scale=2; $b_accent/255" | bc)
    
    sudo tee -a "$PLYMOUTH_THEME_DIR/$THEME_NAME.script" > /dev/null << EOF

# Accent color values (normalized 0-1)
accent_r = $r_accent_norm;
accent_g = $g_accent_norm;
accent_b = $b_accent_norm;

# Create title text
title_image = Image.Text("$THEME_NAME", 1, 1, 1, 1, "Monospace 24");
title_sprite = Sprite(title_image);
title_sprite.SetPosition(screen_x + (screen_width / 2) - (title_image.GetWidth() / 2), progress_bar_y + 40, 2);

# Animation state
global.progress = 0;
global.pulse_state = 0;
global.pulse_direction = 1;

# Progress callback function
fun refresh_callback() {
    # Pulse animation
    global.pulse_state += global.pulse_direction * 0.02;
    if (global.pulse_state >= 1) {
        global.pulse_state = 1;
        global.pulse_direction = -1;
    } else if (global.pulse_state <= 0.3) {
        global.pulse_state = 0.3;
        global.pulse_direction = 1;
    }
}

# Boot progress callback
fun boot_progress_callback(time, progress) {
    global.progress = progress;
    
    # Calculate progress bar fill width
    fill_width = Math.Int(progress * progress_bar_width);
    
    # Clear old progress sprites
    for (i = 0; i < progress_bar_width; i++) {
        if (progress_sprites[i]) {
            progress_sprites[i].SetOpacity(0);
        }
    }
    
    # Draw progress bar with accent color
    for (i = 0; i < fill_width; i++) {
        if (!progress_sprites[i]) {
            progress_sprites[i] = Sprite();
        }
        # Create a colored block for progress
        block_img = Image.Text("|", accent_r * global.pulse_state, accent_g * global.pulse_state, accent_b * global.pulse_state);
        progress_sprites[i].SetImage(block_img);
        progress_sprites[i].SetPosition(progress_bar_x + i, progress_bar_y, 2);
        progress_sprites[i].SetOpacity(1);
    }
}

# Password prompt
fun password_dialogue_setup(title, bullet) {
    local.box_image = Image.Text("", 0.1, 0.1, 0.1);
    local.lock = Image.Text("*", 1, 1, 1);
    
    box_sprite = Sprite(box_image);
    box_sprite.SetPosition(screen_x + screen_width / 2 - 150, screen_y + screen_height / 2 - 50, 10);
    
    title_sprite = Sprite(Image.Text(title, 1, 1, 1));
    title_sprite.SetPosition(screen_x + screen_width / 2 - 100, screen_y + screen_height / 2 - 40, 11);
    
    global.password_bullets = [];
    return local.lock;
}

fun password_dialogue_opacity(opacity) {
    box_sprite.SetOpacity(opacity);
    title_sprite.SetOpacity(opacity);
    for (i = 0; i < global.password_bullets.size(); i++) {
        global.password_bullets[i].SetOpacity(opacity);
    }
}

# Message display
fun display_message_callback(text) {
    message_sprite = Sprite(Image.Text(text, 0.7, 0.7, 0.7, 1, "Monospace 12"));
    message_sprite.SetPosition(screen_x + 10, screen_y + screen_height - 30, 3);
}

fun hide_message_callback(text) {
    message_sprite.SetOpacity(0);
}

# Register callbacks
Plymouth.SetRefreshFunction(refresh_callback);
Plymouth.SetBootProgressFunction(boot_progress_callback);
Plymouth.SetMessageFunction(display_message_callback);
Plymouth.SetHideMessageFunction(hide_message_callback);
EOF

    # Set permissions
    sudo chmod 644 "$PLYMOUTH_THEME_DIR/$THEME_NAME.plymouth"
    sudo chmod 644 "$PLYMOUTH_THEME_DIR/$THEME_NAME.script"
    
    # Configure Plymouth to use this theme (optional, user may need to rebuild initramfs)
    if command -v plymouth-set-default-theme &>/dev/null; then
        log "Setting Plymouth theme (you may need to rebuild initramfs)..."
        sudo plymouth-set-default-theme -R "$THEME_NAME" 2>/dev/null || \
            log "Warning: Could not set Plymouth theme automatically. Run: sudo plymouth-set-default-theme -R $THEME_NAME"
    else
        log "Plymouth theme created. To activate, run:"
        log "  sudo plymouth-set-default-theme -R $THEME_NAME"
        log "  sudo mkinitcpio -P  # For Arch Linux"
    fi
    
    log "Plymouth boot theme created"
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
        local lookfeel_id="com.github.abyss${THEME_VARIANT:+.${THEME_VARIANT,,}}"
        if [[ "$LOOKANDFEELTOOL" == "plasma-apply-lookandfeel" ]]; then
            $LOOKANDFEELTOOL -a "$lookfeel_id" 2>/dev/null || true
        else
            $LOOKANDFEELTOOL -a "$lookfeel_id" 2>/dev/null || true
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
    $KWRITECONFIG --file kdeglobals --group KDE --key LookAndFeelPackage "com.github.abyss${THEME_VARIANT:+.${THEME_VARIANT,,}}"
    
    # Window decorations - use Aurorae with our theme
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key theme "__aurorae__svg__$THEME_NAME"
    
    # Icon theme
    $KWRITECONFIG --file kdeglobals --group Icons --key Theme breeze-dark
    
    # Cursor theme
    $KWRITECONFIG --file kcminputrc --group Mouse --key cursorTheme breeze_cursors
    
    # Configure Kvantum as the Qt style
    $KWRITECONFIG --file kdeglobals --group KDE --key widgetStyle kvantum
    
    # Set environment variable for Qt apps to use Kvantum (via profile)
    if [[ ! -f "$HOME/.config/environment.d/kvantum.conf" ]]; then
        mkdir -p "$HOME/.config/environment.d"
        cat > "$HOME/.config/environment.d/kvantum.conf" << EOF
QT_STYLE_OVERRIDE=kvantum
EOF
        log "Created Kvantum environment configuration"
    fi
    
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
    create_kvantum_theme
    create_aurorae_theme
    create_lookfeel_package
    create_sddm_theme
    configure_sddm
    create_plymouth_theme
    apply_plasma_settings
    
    log "Installation complete!"
    log ""
    log "Next steps:"
    log "1. Restart Plasma: killall plasmashell && plasmashell &"
    log "2. Or reboot for SDDM and Plymouth themes"
    log "3. System Settings > Appearance > Global Theme > $THEME_NAME"
    log "4. For Plymouth: sudo mkinitcpio -P (rebuild initramfs)"
    log "5. Enjoy the void."
}

main "$@"