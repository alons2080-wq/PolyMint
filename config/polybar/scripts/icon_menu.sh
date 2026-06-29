#!/bin/bash

APP=$1

choice=$(echo -e "Abrir nueva ventana\nCerrar aplicación\nMostrar ventanas" | rofi -dmenu -i -p "$APP")

case "$choice" in
  "Abrir nueva ventana") $APP & ;;
  "Cerrar aplicación") pkill -f "$APP" ;;
  "Mostrar ventanas") wmctrl -lx | grep -i "$APP" ;;
esac
