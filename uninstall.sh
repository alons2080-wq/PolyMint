#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==========================================
# COLOR CONFIGURATION (Match with installer)
# ==========================================
COLOR_BANNER="\e[1;35m"      # Magenta
COLOR_TITLE="\e[1;36m"       # Cyan
COLOR_INFO="\e[1;34m"        # Blue
COLOR_SUCCESS="\e[1;32m"     # Green
COLOR_WARNING="\e[1;33m"     # Yellow
COLOR_ERROR="\e[1;31m"       # Red
COLOR_RESET="\e[0m"          # Clear

banner=$(cat << EOF
██████╗  ██████╗ ██╗  ██╗   ██╗███╗   ███╗██╗███╗   ██╗████████╗
██╔══██╗██╔═══██╗██║  ╚██╗ ██╔╝████╗ ████║██║████╗  ██║╚══██╔══╝
██████╔╝██║   ██║██║   ╚████╔╝ ██╔████╔██║██║██╔██╗ ██║   ██║   
██╔═══╝ ██║   ██║██║    ╚██╔╝  ██║╚██╔╝██║██║██║╚██╗██║   ██║   
██║     ╚██████╔╝███████╗██║   ██║ ╚═╝ ██║██║██║ ╚████║   ██║   
╚═╝      ╚═════╝ ╚══════╝╚═╝   ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝   ╚═╝   
EOF
)

clear
echo -e "${COLOR_BANNER}${banner}${COLOR_RESET}"
echo -e "${COLOR_TITLE}Uninstaller Script - PolyMint${COLOR_RESET}\n"

# ==========================================
# ANIMATION FUNCTIONS
# ==========================================
animate_action() {
    local message="$1"
    local command="$2"
    echo -n "$message... "
    
    eval "$command" >/dev/null 2>&1 &
    local pid=$!
    local spin='-\|/'

    while kill -0 $pid 2>/dev/null; do
        for i in {0..3}; do
            echo -ne "${COLOR_WARNING}${spin:$i:1}${COLOR_RESET}\b"
            sleep 0.1
        done
    done
    
    wait $pid && status=$? || status=$?

    if [ $status -eq 0 ]; then
        echo -e "${COLOR_SUCCESS}✓ Done${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}✗ Failed or Not Found${COLOR_RESET}"
    fi
}

show_progress() {
    local message="$1"
    echo -e "$message..."
    local progress=""
    for i in {1..22}; do
        progress+="█"
        echo -ne "${COLOR_ERROR}\r$progress $((i * 100 / 22))%${COLOR_RESET}"
        sleep 0.04
    done
    echo -e "\n"
}

# ==========================================
# DISTRO DETECTION
# ==========================================
if command -v pacman >/dev/null; then DISTRO="arch"
elif command -v apt >/dev/null; then DISTRO="debian"
elif command -v dnf >/dev/null; then DISTRO="fedora"
elif command -v zypper >/dev/null; then DISTRO="opensuse"
fi

# ==========================================
# STOPPING SERVICES
# ==========================================
animate_action "Stopping Polybar processes" "killall polybar || true"

# ==========================================
# REMOVING CONFIGURATIONS
# ==========================================
show_progress "Removing PolyMint configurations"

# Remove current directories
rm -rf "$HOME/.config/polybar"
rm -rf "$HOME/.config/rofi"

# Restore backup if it exists
if [ -d "$HOME/.config/polybar.backup" ]; then
    animate_action "Restoring original Polybar backup" "mv \$HOME/.config/polybar.backup \$HOME/.config/polybar"
fi

# Remove autostart shortcut
animate_action "Removing autostart entry" "rm -f \$HOME/.config/autostart/polymint.desktop"
echo ""

# ==========================================
# OPTIONAL: REMOVE FONTS
# ==========================================
read -p "Do you want to remove the downloaded fonts? (y/N): " rm_fonts
if [[ "$rm_fonts" =~ ^[Yy]$ ]]; then
    echo -n "Removing fonts... "
    rm -f "$HOME/.local/share/fonts/NotoColorEmoji.ttf" 2>/dev/null || true
    # Find and remove JetBrainsMono files specifically if needed, or clear the directory carefully
    find "$HOME/.local/share/fonts" -type f -name "*JetBrainsMono*" -delete 2>/dev/null || true
    fc-cache -f >/dev/null 2>&1
    echo -e "${COLOR_SUCCESS}✓ Fonts removed and cache updated.${COLOR_RESET}\n"
fi

# ==========================================
# OPTIONAL: UNINSTALL SYSTEM DEPENDENCIES
# ==========================================
read -p "Do you want to uninstall system packages (polybar, rofi, kitty, etc.)? (y/N): " rm_pkgs
if [[ "$rm_pkgs" =~ ^[Yy]$ ]]; then
    echo -e "${COLOR_INFO}Uninstalling system packages (SUDO required)...${COLOR_RESET}"
    case "$DISTRO" in
        arch)
            sudo pacman -Rns polybar rofi wmctrl xdotool networkmanager playerctl brightnessctl pavucontrol
            ;;
        debian)
            sudo apt purge -y polybar rofi wmctrl xdotool network-manager playerctl brightnessctl pavucontrol
            sudo apt autoremove -y
            ;;
        fedora)
            sudo dnf remove -y polybar rofi wmctrl xdotool NetworkManager playerctl brightnessctl pavucontrol
            ;;
        opensuse)
            sudo zypper remove -y polybar rofi wmctrl xdotool NetworkManager playerctl brightnessctl pavucontrol
            ;;
    esac
fi

echo -e "\n${COLOR_SUCCESS}PolyMint has been uninstalled successfully.${COLOR_RESET}"

