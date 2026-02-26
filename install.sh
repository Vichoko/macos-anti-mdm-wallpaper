#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# install.sh - Instalador del sistema anti-MDM wallpaper
# -----------------------------------------------------------------------------
# Este script configura automáticamente el LaunchAgent que vigila y restaura
# el wallpaper cuando MDM intenta cambiarlo.
#
# Uso:
#   ./install.sh
#
# Lo que hace:
#   1. Detecta la ruta actual del script
#   2. Da permisos de ejecución a todos los scripts
#   3. Crea/actualiza el archivo plist del LaunchAgent
#   4. Descarga y recarga el LaunchAgent
#   5. Verifica que esté funcionando
# -----------------------------------------------------------------------------

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Instalador anti-MDM wallpaper"
echo "================================"
echo ""

# Detectar la ruta absoluta de este script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "📁 Directorio de instalación: $SCRIPT_DIR"

# Detectar usuario actual
CURRENT_USER="$(whoami)"
PLIST_PATH="$HOME/Library/LaunchAgents/com.vicente.check_wallpaper.plist"
LABEL="com.vicente.check_wallpaper"

echo "👤 Usuario: $CURRENT_USER"
echo ""

# Verificar que los scripts necesarios existan
REQUIRED_SCRIPTS=(
    "check_and_fix_wallpaper.sh"
    "current_wallpaper.sh"
    "set_wallpaper.sh"
    "close_aerial.sh"
    "open_aerial.sh"
)

echo "🔍 Verificando scripts..."
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [[ ! -f "$SCRIPT_DIR/$script" ]]; then
        echo -e "${RED}❌ Error: No se encontró $script${NC}"
        exit 1
    fi
    echo "  ✓ $script"
done
echo ""

# Dar permisos de ejecución
echo "🔧 Configurando permisos de ejecución..."
for script in "${REQUIRED_SCRIPTS[@]}"; do
    chmod +x "$SCRIPT_DIR/$script"
    echo "  ✓ chmod +x $script"
done
echo ""

# Actualizar SCRIPT_DIR en check_and_fix_wallpaper.sh
echo "📝 Actualizando rutas en check_and_fix_wallpaper.sh..."
sed -i '' "s|^SCRIPT_DIR=.*|SCRIPT_DIR=\"$SCRIPT_DIR\"|" "$SCRIPT_DIR/check_and_fix_wallpaper.sh"
echo "  ✓ SCRIPT_DIR actualizado"
echo ""

# Crear directorio LaunchAgents si no existe
mkdir -p "$HOME/Library/LaunchAgents"

# Descargar LaunchAgent si ya está cargado
echo "🛑 Descargando LaunchAgent anterior (si existe)..."
launchctl unload "$PLIST_PATH" 2>/dev/null && echo "  ✓ LaunchAgent descargado" || echo "  ℹ️  No había LaunchAgent cargado previamente"
# Esperar un momento para asegurar que se descargó
sleep 1
echo ""

# Crear el archivo plist
echo "📄 Creando archivo LaunchAgent..."
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>

  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_DIR/check_and_fix_wallpaper.sh</string>
  </array>

  <key>StartInterval</key>
  <integer>60</integer>

  <key>RunAtLoad</key>
  <true/>

  <key>StandardOutPath</key>
  <string>/tmp/check_wallpaper.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/check_wallpaper.err</string>
</dict>
</plist>
EOF
echo "  ✓ Archivo creado: $PLIST_PATH"
echo ""

# Cargar el LaunchAgent
echo "🚀 Cargando LaunchAgent..."
if launchctl load "$PLIST_PATH" 2>/dev/null; then
    echo "  ✓ LaunchAgent cargado"
else
    # Si falla, puede ser que ya esté cargado, intentar recargar
    echo "  ⟳ Recargando LaunchAgent..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    sleep 1
    launchctl load "$PLIST_PATH" 2>/dev/null || echo "  ⚠️  Advertencia al cargar"
fi
echo "  ⏳ Esperando que el LaunchAgent se registre..."
sleep 4
echo ""

# Verificar estado
echo "✅ Verificando instalación..."
if launchctl list | grep -q "$LABEL"; then
    STATUS=$(launchctl list | grep "$LABEL" | awk '{print $1}')
    if [[ "$STATUS" == "-" ]]; then
        echo -e "${GREEN}✓ LaunchAgent cargado exitosamente (en espera)${NC}"
    else
        echo -e "${GREEN}✓ LaunchAgent cargado exitosamente (PID: $STATUS)${NC}"
    fi
else
    echo -e "${RED}❌ Error: LaunchAgent no se cargó correctamente${NC}"
    exit 1
fi
echo ""

# Probar ejecución manual
echo "🧪 Probando ejecución del script..."
if "$SCRIPT_DIR/check_and_fix_wallpaper.sh"; then
    echo -e "${GREEN}✓ Script ejecuta correctamente${NC}"
else
    echo -e "${YELLOW}⚠️  Script ejecutó pero no detectó cambios (esto es normal)${NC}"
fi
echo ""

# Información final
echo "================================"
echo -e "${GREEN}🎉 Instalación completada exitosamente${NC}"
echo ""
echo "ℹ️  Información:"
echo "   • El script se ejecuta cada 60 segundos"
echo "   • Logs de actividad: /tmp/check_wallpaper.log"
echo "   • Logs de errores: /tmp/check_wallpaper.err"
echo ""
echo "📋 Comandos útiles:"
echo "   • Ver logs: tail -f /tmp/check_wallpaper.log"
echo "   • Ver estado: launchctl list | grep check_wallpaper"
echo "   • Desinstalar: ./uninstall.sh"
echo ""
