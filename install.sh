#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# ==========================================
# COLOR CONFIGURATION (Customize your style here)
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
echo -e "${COLOR_TITLE}Installer Script - PolyMint${COLOR_RESET}\n"

# ==========================================
# ANIMATION FUNCTIONS
# ==========================================

# Dynamic spinner animation for quick system checks
animate_check() {
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
        echo -e "${COLOR_SUCCESS}✓ Installed${COLOR_RESET}"
        return 0
    else
        echo -e "${COLOR_ERROR}✗ Not Found${COLOR_RESET}"
        return 1
    fi
}

# Smooth custom progress bar with Unicode blocks
show_progress() {
    local message="$1"
    echo -e "$message..."
    local progress=""
    for i in {1..22}; do
        progress+="█"
        echo -ne "${COLOR_SUCCESS}\r$progress $((i * 100 / 22))%${COLOR_RESET}"
        sleep 0.04
    done
    echo -e "\n"
}

# ==========================================
# DISTRO DETECTION
# ==========================================
echo -n "Checking distribution... "
if command -v pacman >/dev/null; then
    DISTRO="arch"
    echo -e "${COLOR_SUCCESS}✓ Arch Linux${COLOR_RESET}\n"
elif command -v apt >/dev/null; then
    DISTRO="debian"
    echo -e "${COLOR_SUCCESS}✓ Debian/Ubuntu${COLOR_RESET}\n"
elif command -v dnf >/dev/null; then
    DISTRO="fedora"
    echo -e "${COLOR_SUCCESS}✓ Fedora${COLOR_RESET}\n"
elif command -v zypper >/dev/null; then
    DISTRO="opensuse"
    echo -e "${COLOR_SUCCESS}✓ openSUSE${COLOR_RESET}\n"
else
    echo -e "${COLOR_ERROR}✗ Unsupported distribution.${COLOR_RESET}"
    exit 1
fi

# ==========================================
# CHECK DEPENDENCIES
# ==========================================
animate_check "Checking Polybar" "command -v polybar" || true
animate_check "Checking Rofi" "command -v rofi" || true
echo ""

# ==========================================
# SYSTEM DEPENDENCIES INSTALLATION
# ==========================================
echo -e "${COLOR_INFO}Installing system dependencies (SUDO required)...${COLOR_RESET}"

case "$DISTRO" in
    arch)
        sudo pacman -S --needed --noconfirm polybar rofi python kitty nemo wmctrl xdotool networkmanager playerctl brightnessctl pavucontrol wget unzip
        ;;
    debian)
        sudo apt update
        sudo apt install -y polybar rofi python3 kitty nemo wmctrl xdotool network-manager playerctl brightnessctl pavucontrol wget unzip
        ;;
    fedora)
        sudo dnf install -y polybar rofi python3 kitty nemo wmctrl xdotool NetworkManager playerctl brightnessctl pavucontrol wget unzip
        ;;
    opensuse)
        sudo zypper install -y polybar rofi python3 kitty nemo wmctrl xdotool NetworkManager playerctl brightnessctl pavucontrol wget unzip
        ;;
esac
echo ""

# ==========================================
# AUTOMATIC NERD FONTS & EMOJI DOWNLOAD
# ==========================================
echo -e "${COLOR_INFO}Checking fonts installation...${COLOR_RESET}"

# Setup local font directory path
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Check and install JetBrainsMono Nerd Font if not available globally/locally
if ! fc-list : family | grep -qi "JetBrainsMono"; then
    echo -e "${COLOR_WARNING}JetBrainsMono Nerd Font not found. Downloading from GitHub...${COLOR_RESET}"
    TEMP_DIR=$(mktemp -d)
    
    # Download directly from official releases repository
    wget -q --show-progress -O "$TEMP_DIR/JetBrainsMono.zip" "https://github.com"
    unzip -q "$TEMP_DIR/JetBrainsMono.zip" -d "$TEMP_DIR"
    
    # Move actual font files to the font directory
    mv "$TEMP_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null || true
    rm -rf "$TEMP_DIR"
    echo -e "${COLOR_SUCCESS}✓ JetBrainsMono Nerd Font installed.${COLOR_RESET}\n"
else
    echo -e "${COLOR_SUCCESS}✓ JetBrainsMono Nerd Font already available.${COLOR_RESET}"
fi

# Check and install Noto Color Emoji if not available
if ! fc-list : family | grep -qi "Noto Color Emoji"; then
    echo -e "${COLOR_WARNING}Noto Color Emoji not found. Downloading from GitHub...${COLOR_RESET}"
    
    # Download directly from googlefonts official repository assets
    wget -q --show-progress -O "$FONT_DIR/NotoColorEmoji.ttf" "https://github.com"
    echo -e "${COLOR_SUCCESS}✓ Noto Color Emoji installed.${COLOR_RESET}\n"
else
    echo -e "${COLOR_SUCCESS}✓ Noto Color Emoji already available.${COLOR_RESET}"
fi

# Refresh fonts cache
echo -n "Updating font cache... "
fc-cache -f >/dev/null 2>&1
echo -e "${COLOR_SUCCESS}Done${COLOR_RESET}\n"

# ==========================================
# CONFIGURATION & BACKUPS
# ==========================================

# 1. Backup if old directory exists
if [ -d "$HOME/.config/polybar" ]; then
    mv "$HOME/.config/polybar" "$HOME/.config/polybar.backup"
    echo -e "Creating backup...\n${COLOR_SUCCESS}✓ Done${COLOR_RESET}\n"
fi

# 2. Deploy Configuration files
mkdir -p "$HOME/.config/polybar"
mkdir -p "$HOME/.config/rofi"

if [ -d "config/polybar" ] && [ -d "config/rofi" ]; then
    cp -r config/polybar/* "$HOME/.config/polybar/"
    cp -r config/rofi/* "$HOME/.config/rofi/"
fi

# Apply executable execution privileges
chmod +x "$HOME/.config/polybar/scripts/"* 2>/dev/null || true
chmod +x "$HOME/.config/rofi/"*.sh 2>/dev/null || true

show_progress "Installing configuration"
show_progress "Installing fonts"

# ==========================================
# AUTOSTART SETUP
# ==========================================
mkdir -p "$HOME/.config/autostart"

cat << EOF > "$HOME/.config/autostart/polymint.desktop"
[Desktop Entry]
Type=Application
Name=PolyMint
Exec=$HOME/.config/polybar/launch.sh
X-GNOME-Autostart-enabled=true
EOF

echo -e "Creating autostart...\n${COLOR_SUCCESS}✓ Done${COLOR_RESET}\n"

# ==========================================
# RESTART SERVICES
# ==========================================
echo "Restarting Polybar..."
killall polybar 2>/dev/null || true

if [ -f "$HOME/.config/polybar/launch.sh" ]; then
    chmod +x "$HOME/.config/polybar/launch.sh"
    "$HOME/.config/polybar/launch.sh" &
fi
echo -e "${COLOR_SUCCESS}✓ Done${COLOR_RESET}\n"

echo -e "${COLOR_WARNING}PolyMint installed successfully.${COLOR_RESET}"

