#!/usr/bin/env bash
#
# ABYSS - KDE Plasma Monochrome Theme Uninstaller
# Safely removes all Abyss theme components
#

set -euo pipefail

# ============================================================================
# CONFIGURATION
# ============================================================================

THEME_NAME="Abyss"
THEME_DIR="$HOME/.local/share/plasma/desktoptheme/$THEME_NAME"
LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss"
SDDM_THEME_DIR="/usr/share/sddm/themes/$THEME_NAME"
GTK_THEME_DIR="$HOME/.themes/$THEME_NAME"
WALLPAPER_DIR="$HOME/.local/share/wallpapers/$THEME_NAME"
COLOR_SCHEME="$HOME/.local/share/color-schemes/$THEME_NAME.colors"
KVANTUM_DIR="$HOME/.config/Kvantum/$THEME_NAME"
AURORAE_DIR="$HOME/.local/share/aurorae/themes/$THEME_NAME"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/$THEME_NAME"

# Theme variants to remove
THEME_VARIANTS=("Abyss" "Abyss-Crimson" "Abyss-Cobalt" "Abyss-Emerald")

# ============================================================================
# FUNCTIONS
# ============================================================================

log() {
    echo "[ABYSS] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

warn() {
    echo "[WARN] $*"
}

confirm() {
    local prompt="$1"
    local response
    read -r -p "[ABYSS] $prompt [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

# Detect Plasma version and set appropriate command names
detect_plasma_version() {
    if command -v kwriteconfig6 &>/dev/null; then
        KWRITECONFIG="kwriteconfig6"
        PLASMA_VERSION=6
    else
        KWRITECONFIG="kwriteconfig5"
        PLASMA_VERSION=5
    fi
    
    if command -v lookandfeeltool &>/dev/null; then
        LOOKANDFEELTOOL="lookandfeeltool"
    elif command -v plasma-apply-lookandfeel &>/dev/null; then
        LOOKANDFEELTOOL="plasma-apply-lookandfeel"
    else
        LOOKANDFEELTOOL=""
    fi
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "Do not run this script as root. SDDM removal will use sudo when needed."
        exit 1
    fi
}

remove_plasma_theme() {
    log "Removing Plasma desktop theme..."
    
    if [[ -d "$THEME_DIR" ]]; then
        rm -rf "$THEME_DIR"
        log "  Removed: $THEME_DIR"
    else
        warn "  Not found: $THEME_DIR"
    fi
}

remove_lookfeel_package() {
    log "Removing Look-and-Feel package..."
    
    if [[ -d "$LOOKFEEL_DIR" ]]; then
        rm -rf "$LOOKFEEL_DIR"
        log "  Removed: $LOOKFEEL_DIR"
    else
        warn "  Not found: $LOOKFEEL_DIR"
    fi
}

remove_color_scheme() {
    log "Removing color scheme..."
    
    if [[ -f "$COLOR_SCHEME" ]]; then
        rm -f "$COLOR_SCHEME"
        log "  Removed: $COLOR_SCHEME"
    else
        warn "  Not found: $COLOR_SCHEME"
    fi
}

remove_gtk_themes() {
    log "Removing GTK themes..."
    
    if [[ -d "$GTK_THEME_DIR" ]]; then
        rm -rf "$GTK_THEME_DIR"
        log "  Removed: $GTK_THEME_DIR"
    else
        warn "  Not found: $GTK_THEME_DIR"
    fi
}

remove_wallpaper() {
    log "Removing wallpaper..."
    
    if [[ -d "$WALLPAPER_DIR" ]]; then
        rm -rf "$WALLPAPER_DIR"
        log "  Removed: $WALLPAPER_DIR"
    else
        warn "  Not found: $WALLPAPER_DIR"
    fi
}

remove_sddm_theme() {
    log "Removing SDDM theme..."
    
    # Remove all variants
    for variant in "${THEME_VARIANTS[@]}"; do
        local sddm_dir="/usr/share/sddm/themes/$variant"
        if [[ -d "$sddm_dir" ]]; then
            sudo rm -rf "$sddm_dir"
            log "  Removed: $sddm_dir"
        fi
    done
    
    # Remove SDDM configuration
    if [[ -f "/etc/sddm.conf.d/abyss.conf" ]]; then
        sudo rm -f "/etc/sddm.conf.d/abyss.conf"
        log "  Removed: /etc/sddm.conf.d/abyss.conf"
    fi
}

remove_kvantum_theme() {
    log "Removing Kvantum theme..."
    
    # Remove all variants
    for variant in "${THEME_VARIANTS[@]}"; do
        local kvantum_dir="$HOME/.config/Kvantum/$variant"
        if [[ -d "$kvantum_dir" ]]; then
            rm -rf "$kvantum_dir"
            log "  Removed: $kvantum_dir"
        fi
    done
    
    # Reset Kvantum config if it was set to Abyss
    local kvantum_config="$HOME/.config/Kvantum/kvantum.kvconfig"
    if [[ -f "$kvantum_config" ]]; then
        if grep -q "theme=Abyss" "$kvantum_config" 2>/dev/null; then
            rm -f "$kvantum_config"
            log "  Removed Kvantum configuration"
        fi
    fi
}

remove_aurorae_theme() {
    log "Removing Aurorae window decoration theme..."
    
    # Remove all variants
    for variant in "${THEME_VARIANTS[@]}"; do
        local aurorae_dir="$HOME/.local/share/aurorae/themes/$variant"
        if [[ -d "$aurorae_dir" ]]; then
            rm -rf "$aurorae_dir"
            log "  Removed: $aurorae_dir"
        fi
    done
}

remove_plymouth_theme() {
    log "Removing Plymouth boot theme..."
    
    # Remove all variants
    for variant in "${THEME_VARIANTS[@]}"; do
        local plymouth_dir="/usr/share/plymouth/themes/$variant"
        if [[ -d "$plymouth_dir" ]]; then
            sudo rm -rf "$plymouth_dir"
            log "  Removed: $plymouth_dir"
        fi
    done
    
    # Check if Plymouth was using our theme and reset to default
    if command -v plymouth-set-default-theme &>/dev/null; then
        local current_theme
        current_theme=$(plymouth-set-default-theme 2>/dev/null || echo "")
        for variant in "${THEME_VARIANTS[@]}"; do
            if [[ "$current_theme" == "$variant" ]]; then
                log "Resetting Plymouth theme to default..."
                sudo plymouth-set-default-theme -R spinner 2>/dev/null || \
                    log "Warning: Could not reset Plymouth theme. You may need to set it manually."
                break
            fi
        done
    fi
}

reset_gtk_settings() {
    log "Resetting GTK settings to Breeze..."
    
    # GTK3 settings
    if [[ -f "$HOME/.config/gtk-3.0/settings.ini" ]]; then
        cat > "$HOME/.config/gtk-3.0/settings.ini" << EOF
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=breeze
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=0
EOF
        log "  Reset: ~/.config/gtk-3.0/settings.ini"
    fi
    
    # GTK4 settings
    if [[ -f "$HOME/.config/gtk-4.0/settings.ini" ]]; then
        cat > "$HOME/.config/gtk-4.0/settings.ini" << EOF
[Settings]
gtk-theme-name=Breeze
gtk-icon-theme-name=breeze
gtk-font-name=Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-cursor-theme-size=24
EOF
        log "  Reset: ~/.config/gtk-4.0/settings.ini"
    fi
}

reset_plasma_settings() {
    log "Resetting Plasma settings to Breeze..."
    
    # Reset to Breeze look and feel
    if [[ -n "$LOOKANDFEELTOOL" ]]; then
        $LOOKANDFEELTOOL -a org.kde.breeze.desktop 2>/dev/null || true
    fi
    
    # Reset color scheme
    $KWRITECONFIG --file kdeglobals --group General --key ColorScheme "Breeze"
    
    # Reset Plasma theme
    $KWRITECONFIG --file plasmarc --group Theme --key name "default"
    
    # Reset icon theme
    $KWRITECONFIG --file kdeglobals --group Icons --key Theme "breeze"
    
    # Reset cursor theme
    $KWRITECONFIG --file kcminputrc --group Mouse --key cursorTheme "breeze_cursors"
    
    # Reset look and feel package
    $KWRITECONFIG --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breeze.desktop"
    
    # Reset window decoration to Breeze
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key library org.kde.breeze
    $KWRITECONFIG --file kwinrc --group org.kde.kdecoration2 --key theme Breeze
    
    # Reset Qt style from Kvantum to Breeze
    $KWRITECONFIG --file kdeglobals --group KDE --key widgetStyle Breeze
    
    # Remove Kvantum environment configuration
    if [[ -f "$HOME/.config/environment.d/kvantum.conf" ]]; then
        rm -f "$HOME/.config/environment.d/kvantum.conf"
        log "  Removed Kvantum environment configuration"
    fi
    
    log "  Plasma settings reset to Breeze defaults"
}

clear_cache() {
    log "Clearing Plasma cache..."
    
    rm -rf "$HOME/.cache/plasma"* 2>/dev/null || true
    rm -rf "$HOME/.cache/kioexec"* 2>/dev/null || true
    rm -rf "$HOME/.cache/icon-cache.kcache" 2>/dev/null || true
    
    # Rebuild sycoca cache
    if command -v kbuildsycoca5 &>/dev/null; then
        kbuildsycoca5 --noincremental 2>/dev/null || true
    elif command -v kbuildsycoca6 &>/dev/null; then
        kbuildsycoca6 --noincremental 2>/dev/null || true
    fi
    
    log "  Cache cleared"
}

show_summary() {
    log ""
    log "============================================"
    log "Uninstallation complete!"
    log "============================================"
    log ""
    log "Removed components:"
    log "  - Plasma desktop theme"
    log "  - Look-and-Feel package"
    log "  - Color scheme"
    log "  - GTK themes"
    log "  - Kvantum theme"
    log "  - Aurorae window decoration"
    log "  - Wallpapers"
    log "  - SDDM theme (if applicable)"
    log "  - Plymouth boot theme (if applicable)"
    log ""
    log "Settings have been reset to Breeze defaults."
    log ""
    log "Next steps:"
    log "  1. Restart Plasma: killall plasmashell && plasmashell &"
    log "  2. Or reboot for complete reset (including SDDM and Plymouth)"
    log "  3. For Plymouth: sudo mkinitcpio -P (rebuild initramfs)"
    log ""
}

show_help() {
    cat << EOF
ABYSS Theme Uninstaller

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -y, --yes           Skip confirmation prompts
    --keep-wallpaper    Keep the Abyss wallpaper
    --keep-gtk          Keep the GTK theme
    --keep-kvantum      Keep the Kvantum theme
    --keep-aurorae      Keep the Aurorae window decoration
    --keep-sddm         Skip SDDM theme removal
    --keep-plymouth     Skip Plymouth theme removal
    --no-reset          Don't reset Plasma/GTK settings to Breeze

Examples:
    $0                  Interactive uninstall with confirmation
    $0 -y               Uninstall without confirmation
    $0 --keep-wallpaper Uninstall but keep the wallpaper
    $0 --keep-kvantum   Uninstall but keep Kvantum theme
EOF
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    local skip_confirm=false
    local keep_wallpaper=false
    local keep_gtk=false
    local keep_kvantum=false
    local keep_aurorae=false
    local keep_sddm=false
    local keep_plymouth=false
    local no_reset=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -y|--yes)
                skip_confirm=true
                shift
                ;;
            --keep-wallpaper)
                keep_wallpaper=true
                shift
                ;;
            --keep-gtk)
                keep_gtk=true
                shift
                ;;
            --keep-kvantum)
                keep_kvantum=true
                shift
                ;;
            --keep-aurorae)
                keep_aurorae=true
                shift
                ;;
            --keep-sddm)
                keep_sddm=true
                shift
                ;;
            --keep-plymouth)
                keep_plymouth=true
                shift
                ;;
            --no-reset)
                no_reset=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log "Abyss Theme Uninstaller"
    log ""
    
    check_root
    detect_plasma_version
    
    log "Detected Plasma version: $PLASMA_VERSION"
    log ""
    
    # Confirm uninstallation
    if [[ "$skip_confirm" != true ]]; then
        log "This will remove the following (all variants):"
        log "  - Plasma desktop themes"
        log "  - Look-and-Feel packages"
        log "  - Color schemes"
        [[ "$keep_gtk" != true ]] && log "  - GTK themes"
        [[ "$keep_kvantum" != true ]] && log "  - Kvantum themes"
        [[ "$keep_aurorae" != true ]] && log "  - Aurorae window decorations"
        [[ "$keep_wallpaper" != true ]] && log "  - Wallpapers"
        [[ "$keep_sddm" != true ]] && log "  - SDDM themes"
        [[ "$keep_plymouth" != true ]] && log "  - Plymouth boot themes"
        log ""
        
        if ! confirm "Proceed with uninstallation?"; then
            log "Uninstallation cancelled."
            exit 0
        fi
        log ""
    fi
    
    # Remove components for all variants
    for variant in "${THEME_VARIANTS[@]}"; do
        THEME_NAME="$variant"
        THEME_DIR="$HOME/.local/share/plasma/desktoptheme/$THEME_NAME"
        
        # Determine look-and-feel ID
        case "$variant" in
            Abyss) LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss" ;;
            Abyss-Crimson) LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss.crimson" ;;
            Abyss-Cobalt) LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss.cobalt" ;;
            Abyss-Emerald) LOOKFEEL_DIR="$HOME/.local/share/plasma/look-and-feel/com.github.abyss.emerald" ;;
        esac
        
        GTK_THEME_DIR="$HOME/.themes/$THEME_NAME"
        WALLPAPER_DIR="$HOME/.local/share/wallpapers/$THEME_NAME"
        COLOR_SCHEME="$HOME/.local/share/color-schemes/$THEME_NAME.colors"
        
        remove_plasma_theme
        remove_lookfeel_package
        remove_color_scheme
        
        [[ "$keep_gtk" != true ]] && remove_gtk_themes
        [[ "$keep_wallpaper" != true ]] && remove_wallpaper
    done
    
    # Remove shared components (call once for all variants)
    [[ "$keep_kvantum" != true ]] && remove_kvantum_theme
    [[ "$keep_aurorae" != true ]] && remove_aurorae_theme
    [[ "$keep_sddm" != true ]] && remove_sddm_theme
    [[ "$keep_plymouth" != true ]] && remove_plymouth_theme
    
    # Reset settings
    if [[ "$no_reset" != true ]]; then
        reset_gtk_settings
        reset_plasma_settings
    fi
    
    clear_cache
    show_summary
}

main "$@"

