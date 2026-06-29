#!/bin/bash

ICON="$1"
CLASS="$2"

COUNT=$(wmctrl -lx | grep -i "$CLASS" | grep -v "desktop" | wc -l)

if [ "$COUNT" -gt 0 ]; then
    echo "$ICON ●$COUNT"
else
    echo "$ICON"
fi
