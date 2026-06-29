#!/bin/bash

APP="$1"
CLASS="$2"

# buscar ventana exacta (mejor coincidencia)
WIN_ID=$(wmctrl -lx | awk -v cls="$CLASS" '
tolower($3) ~ tolower(cls) {print $1; exit}
')

# si no existe → abrir
if [ -z "$WIN_ID" ]; then
    $APP &
    exit 0
fi

ACTIVE=$(xdotool getactivewindow 2>/dev/null)

# si está activa → minimizar
if [ "$ACTIVE" = "$WIN_ID" ]; then
    xdotool windowminimize "$WIN_ID"
else
    wmctrl -ia "$WIN_ID"
fi
