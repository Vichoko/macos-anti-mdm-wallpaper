#!/usr/bin/env bash

# Script para mostrar el/los fondos de pantalla actuales en macOS

osascript <<'EOF'
tell application "System Events"
    set picList to picture of every desktop
end tell

set text item delimiters to linefeed
return picList as text
EOF
