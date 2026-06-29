#!/bin/bash

# Función para lanzar aplicaciones de forma segura en segundo plano
launch() {
    "$@" & disown
    exit 0
}

# Estado inicial del menú
MENU="main"

while true; do
    case "$MENU" in
        "main")
            # Usamos -show-icons y el formato \0icon\x1f para pasar íconos del sistema a rofi
            CHOICE=$(echo -e "󰍉 Apps\0icon\x1fapplications-interactivity\n Files\0icon\x1fsystem-file-manager\n⚙ System\0icon\x1fpreferences-system\n Network\0icon\x1fnetwork-workgroup\n Power\0icon\x1fsystem-shutdown\n󰍯 All Apps\0icon\x1fsystem-run" | rofi -dmenu -i -show-icons -p "Menu Principal")
            
            case "$CHOICE" in
                "󰍉 Apps")     MENU="apps" ;;
                " Files")    launch nemo ;;
                "⚙ System")   MENU="system" ;;
                " Network")  launch nm-connection-editor ;;
                " Power")    MENU="power" ;;
                "󰍯 All Apps") 
                    # El modo 'drun' nativo es la forma más moderna de buscar apps con íconos y nombres reales
                    rofi -show drun -show-icons
                    exit 0
                    ;;
                *) exit 0 ;; # Si presiona ESC, sale del script
            esac
            ;;
        
        "apps")
            CHOICE=$(echo -e " Web\0icon\x1ffirefox\n Terminal\0icon\x1futility-terminal\n Social\0icon\x1fdiscord\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Categorías")
            case "$CHOICE" in
                " Web")      MENU="web" ;;
                " Terminal")  MENU="term" ;;
                " Social")   MENU="social" ;;
                "󰌪 Volver")   MENU="main" ;;
                *) exit 0 ;;
            esac
            ;;

        "web")
            CHOICE=$(echo -e " Firefox\0icon\x1ffirefox\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Navegadores")
            case "$CHOICE" in
                " Firefox") launch firefox ;;
                "󰌪 Volver")   MENU="apps" ;;
                *) exit 0 ;;
            esac
            ;;

        "term")
            CHOICE=$(echo -e " Kitty\0icon\x1fterminal\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Terminales")
            case "$CHOICE" in
                " Kitty")   launch kitty ;;
                "󰌪 Volver")  MENU="apps" ;;
                *) exit 0 ;;
            esac
            ;;

        "social")
            CHOICE=$(echo -e " Discord\0icon\x1fdiscord\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Social")
            case "$CHOICE" in
                " Discord") launch flatpak run com.discordapp.Discord ;;
                "󰌪 Volver")  MENU="apps" ;;
                *) exit 0 ;;
            esac
            ;;

        "system")
            CHOICE=$(echo -e "Settings\0icon\x1fpreferences-system\nTerminal\0icon\x1fterminal\nRofi drun\0icon\x1fsystem-run\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Sistema")
            case "$CHOICE" in
                "Settings")  launch cinnamon-settings ;;
                "Terminal")  launch kitty ;;
                "Rofi drun") rofi -show drun -show-icons; exit 0 ;;
                "󰌪 Volver") MENU="main" ;;
                *) exit 0 ;;
            esac
            ;;

        "power")
            CHOICE=$(echo -e "Shutdown\0icon\x1fsystem-shutdown\nReboot\0icon\x1fsystem-reboot\nLogout\0icon\x1fsystem-log-out\n󰌪 Volver\0icon\x1fgo-previous" | rofi -dmenu -i -show-icons -p "Energía")
            case "$CHOICE" in
                "Shutdown") systemctl poweroff ;;
                "Reboot")   systemctl reboot ;;
                "Logout")   cinnamon-session-quit ;;
                "󰌪 Volver") MENU="main" ;;
                *) exit 0 ;;
            esac
            ;;
    esac
done
