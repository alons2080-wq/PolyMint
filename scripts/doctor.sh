#!/usr/bin/env bash

# ==========================================
# COLOR CONFIGURATION
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
echo -e "${COLOR_TITLE}Environment Diagnostic Tool - PolyMint${COLOR_RESET}\n"


ERRORS_FOUND=0
WARNINGS_FOUND=0

# ==========================================
# DIAGNOSTIC FUNCTIONS
# ==========================================
check_dependency() {
    local name="$1"
    local cmd="$2"
    echo -n "  Checking $name... "
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${COLOR_SUCCESS}[OK]${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}[MISSING]${COLOR_RESET}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
}

check_font() {
    local font_name="$1"
    echo -n "  Checking $font_name... "
    if fc-list : family | grep -qi "$font_name"; then
        echo -e "${COLOR_SUCCESS}[FOUND]${COLOR_RESET}"
    else
        echo -e "${COLOR_WARNING}[NOT INDEXED]${COLOR_RESET}"
        WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
    fi
}

check_file_dir() {
    local type="$1"
    local path="$2"
    echo -n "  Checking $type path ($path)... "
    if [ -e "$path" ]; then
        echo -e "${COLOR_SUCCESS}[EXISTS]${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}[NOT FOUND]${COLOR_RESET}"
        ERRORS_FOUND=$((ERRORS_FOUND + 1))
    fi
}

# ==========================================
# 1. LIVE SERVICE STATUS
# ==========================================
echo -e "${COLOR_INFO}[1/4] Running Services Status:${COLOR_RESET}"
echo -n "  Polybar active processes... "
if pgrep -x "polybar" >/dev/null; then
    PID_LIST=$(pgrep -x "polybar" | tr '\n' ' ')
    echo -e "${COLOR_SUCCESS}[RUNNING] (PIDs: $PID_LIST)${COLOR_RESET}"
else
    echo -e "${COLOR_WARNING}[NOT RUNNING]${COLOR_RESET}"
    WARNINGS_FOUND=$((WARNINGS_FOUND + 1))
fi
echo ""

# ==========================================
# 2. SYSTEM DEPENDENCIES
# ==========================================
echo -e "${COLOR_INFO}[2/4] Package Dependencies:${COLOR_RESET}"
check_dependency "Polybar" "polybar"
check_dependency "Rofi" "rofi"
check_dependency "Python 3" "python3"
check_dependency "Kitty Terminal" "kitty"
check_dependency "Nemo File Manager" "nemo"
check_dependency "wmctrl" "wmctrl"
check_dependency "xdotool" "xdotool"
check_dependency "Playerctl" "playerctl"
check_dependency "Brightnessctl" "brightnessctl"
check_dependency "Pavucontrol" "pavucontrol"
echo ""

# ==========================================
# 3. FONT REGISTRATION
# ==========================================
echo -e "${COLOR_INFO}[3/4] Required Typography Fonts:${COLOR_RESET}"
check_font "JetBrainsMono"
check_font "Noto Color Emoji"
echo ""

# ==========================================
# 4. PATHS AND PERMISSIONS
# ==========================================
echo -e "${COLOR_INFO}[4/4] Configuration Folders and Executables:${COLOR_RESET}"
check_file_dir "Polybar config" "$HOME/.config/polybar"
check_file_dir "Rofi config" "$HOME/.config/rofi"
check_file_dir "Autostart Desktop Entry" "$HOME/.config/autostart/polymint.desktop"

# Check if launch script is executable
echo -n "  Checking launch.sh executable permission... "
if [ -x "$HOME/.config/polybar/launch.sh" ]; then
    echo -e "${COLOR_SUCCESS}[EXECUTABLE]${COLOR_RESET}"
else
    if [ -f "$HOME/.config/polybar/launch.sh" ]; then
        echo -e "${COLOR_ERROR}[NOT EXECUTABLE]${COLOR_RESET}"
    else
        echo -e "${COLOR_ERROR}[FILE MISSING]${COLOR_RESET}"
    fi
    ERRORS_FOUND=$((ERRORS_FOUND + 1))
fi
echo ""

# ==========================================
# DIAGNOSTIC SUMMARY
# ==========================================
echo -e "${COLOR_TITLE}Diagnostic Summary:${COLOR_RESET}"
echo "------------------------------------------"
if [ $ERRORS_FOUND -eq 0 ] && [ $WARNINGS_FOUND -eq 0 ]; then
    echo -e "${COLOR_SUCCESS}✔ Perfect! Your PolyMint environment is healthy and fully operational.${COLOR_RESET}"
elif [ $ERRORS_FOUND -eq 0 ] && [ $WARNINGS_FOUND -gt 0 ]; then
    echo -e "${COLOR_WARNING}⚠ Warning: Environment has $WARNINGS_FOUND warning(s). Components might function, but visual issues could occur (e.g., polybar process not active or fonts missing).${COLOR_RESET}"
else
    echo -e "${COLOR_ERROR}🗙 Critical: Environment has $ERRORS_FOUND critical error(s) and $WARNINGS_FOUND warning(s). Please run the installer script again to fix missing configurations or packages.${COLOR_RESET}"
fi
echo "------------------------------------------"
