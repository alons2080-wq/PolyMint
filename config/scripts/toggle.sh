#!/bin/bash

APP_CMD=$1
CLASS=$2

# Buscar ventana
WIN=$(wmctrl -lx | grep -i "$CLASS" | awk '{print $1}' | head -n 1)

if [ -z "$WIN" ]; then
    # No existe → abrir
    $APP_CMD &
    exit 0
fi

# Obtener ventana activa
ACTIVE=$(xdotool getactivewindow 2>/dev/null)

# Si está activa → minimizar
if [ "$ACTIVE" = "$WIN" ]; then
    xdotool windowminimize "$WIN"
else
    # Si no está activa → focus
    wmctrl -ia "$WIN"
fi
