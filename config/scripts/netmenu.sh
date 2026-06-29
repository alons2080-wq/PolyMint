#!/bin/bash

# Rofi configuration for consistent styling
ROFI_CMD="rofi -dmenu -i -p 🌐 Network"

# Menu options (easy to expand)
OPTIONS="📶 WiFi Settings
📊 View Connections
✈️ Airplane Mode (Toggle)
⏱️ Speed Test"

# Capture user selection
CHOICE=$(echo -e "$OPTIONS" | $ROFI_CMD)

# Execute action based on selection with state management
case "$CHOICE" in
    *"WiFi Settings"*)
        nm-connection-editor &
        ;;
    *"View Connections"*)
        # Opens connections in a floating terminal to make them visible
        kitty --hold nmcli connection show || alacritty --hold -e nmcli connection show
        ;;
    *"Airplane Mode"*)
        # Dynamically toggles WiFi state (On/Off)
        STATUS=$(nmcli radio wifi)
        if [ "$STATUS" = "enabled" ]; then
            nmcli radio wifi off
            notify-send "Airplane Mode" "WiFi Disabled ✈️"
        else
            nmcli radio wifi on
            notify-send "Airplane Mode" "WiFi Enabled 📶"
        fi
        ;;
    *"Speed Test"*)
        xdg-open "https://speedtest.net" &
        ;;
    *)
        exit 0
        ;;
esac
