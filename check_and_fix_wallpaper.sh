#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# check_and_fix_wallpaper.sh
# -----------------------------------------------------------------------------
# Objetivo
#   Detectar cuándo el wallpaper del usuario fue forzado por ManageEngine a
#   "/Library/ManageEngine/UEMS_Agent/configuration/user/wallpaper/Copy of WallpaperLightModeESPFV.png"
#   y, en ese caso, restaurar el wallpaper deseado y reiniciar Aerial.
#
# Dónde se ejecuta periódicamente (launchd)
#   Este script está configurado como un LaunchAgent de macOS, ejecutándose
#   cada 60 segundos mientras el usuario está logueado.
#
#   Archivo de configuración del LaunchAgent:
#     ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
#
#   Contenido de referencia del .plist (para replicar en otra máquina):
#
#     <?xml version="1.0" encoding="UTF-8"?>
#     <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
#      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
#     <plist version="1.0">
#     <dict>
#       <key>Label</key>
#       <string>com.vicente.check_wallpaper</string>
#
#       <key>ProgramArguments</key>
#       <array>
#         <string>/Users/vicente.oyanedel/git/scripts/check_and_fix_wallpaper.sh</string>
#       </array>
#
#       <key>StartInterval</key>
#       <integer>60</integer>
#
#       <key>RunAtLoad</key>
#       <true/>
#
#       <key>StandardOutPath</key>
#       <string>/tmp/check_wallpaper.log</string>
#       <key>StandardErrorPath</key>
#       <string>/tmp/check_wallpaper.err</string>
#     </dict>
#     </plist>
#
#   Comandos básicos para activarlo/desactivarlo:
#
#     launchctl load  ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
#     launchctl unload ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
#
#   Ver si está cargado:
#
#     launchctl list | grep com.vicente.check_wallpaper
#
# Logs
#   - STDOUT: /tmp/check_wallpaper.log
#   - STDERR: /tmp/check_wallpaper.err
#
#   El script sólo escribe en STDOUT cuando detecta que el wallpaper actual
#   coincide con el forzado por ManageEngine, en cuyo caso registra una línea
#   con timestamp y el mensaje de corrección.
#
#   Ejemplo de línea de log:
#     2025-11-27 23:42:15 - Wallpaper gestionado por ManageEngine detectado, corrigiendo…
#
# Cómo replicar todo en otra máquina (resumen)
#   1. Copiar este script a la ruta deseada, por ejemplo:
#        /Users/OTRO_USUARIO/git/scripts/check_and_fix_wallpaper.sh
#   2. Actualizar en el .plist la ruta del script en <ProgramArguments>.
#   3. Guardar el .plist como:
#        ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
#   4. Dar permisos de ejecución al script:
#        chmod +x /Users/OTRO_USUARIO/git/scripts/check_and_fix_wallpaper.sh
#   5. Cargar el LaunchAgent:
#        launchctl load ~/Library/LaunchAgents/com.vicente.check_wallpaper.plist
#   6. Verificar logs en /tmp/check_wallpaper.log y /tmp/check_wallpaper.err.
# -----------------------------------------------------------------------------

set -euo pipefail

SCRIPT_DIR="/Users/vicente.oyanedel/git/scripts"
TARGET="/Library/ManageEngine/UEMS_Agent/configuration/user/wallpaper/Copy of WallpaperLightModeESPFV.png"

# Capturamos la salida del script actual
current_wallpaper="$("$SCRIPT_DIR/current_wallpaper.sh")"

# Si la respuesta contiene el path objetivo, corremos los otros scripts
if [[ "$current_wallpaper" == *"$TARGET"* ]]; then
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "$timestamp - Wallpaper gestionado por ManageEngine detectado, corrigiendo…"
  "$SCRIPT_DIR/set_wallpaper.sh"
  "$SCRIPT_DIR/close_aerial.sh"
  "$SCRIPT_DIR/open_aerial.sh"
fi
