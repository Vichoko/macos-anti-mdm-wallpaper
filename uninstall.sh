#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# uninstall.sh - Desinstalador del sistema anti-MDM wallpaper
# -----------------------------------------------------------------------------
# Este script elimina el LaunchAgent que vigila el wallpaper.
#
# Uso:
#   ./uninstall.sh
#
# Lo que hace:
#   1. Descarga el LaunchAgent
#   2. Elimina el archivo plist
#   3. Limpia los logs (opcional)
# -----------------------------------------------------------------------------

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🗑️  Desinstalador anti-MDM wallpaper"
echo "===================================="
echo ""

PLIST_PATH="$HOME/Library/LaunchAgents/com.vicente.check_wallpaper.plist"
LABEL="com.vicente.check_wallpaper"

# Verificar si está instalado
if [[ ! -f "$PLIST_PATH" ]]; then
    echo -e "${YELLOW}⚠️  No se encontró instalación existente${NC}"
    exit 0
fi

# Descargar LaunchAgent
echo "🛑 Descargando LaunchAgent..."
if launchctl list | grep -q "$LABEL"; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    echo "  ✓ LaunchAgent descargado"
else
    echo "  ℹ️  LaunchAgent no estaba cargado"
fi
echo ""

# Eliminar archivo plist
echo "🗑️  Eliminando archivo de configuración..."
rm -f "$PLIST_PATH"
echo "  ✓ Archivo eliminado: $PLIST_PATH"
echo ""

# Preguntar si eliminar logs
read -p "¿Eliminar logs (/tmp/check_wallpaper.log y .err)? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f /tmp/check_wallpaper.log /tmp/check_wallpaper.err
    echo "  ✓ Logs eliminados"
fi
echo ""

# Verificar desinstalación
echo "✅ Verificando desinstalación..."
if launchctl list | grep -q "$LABEL"; then
    echo -e "${RED}❌ Error: LaunchAgent sigue cargado${NC}"
    exit 1
else
    echo -e "${GREEN}✓ LaunchAgent desinstalado correctamente${NC}"
fi
echo ""

echo "=================================="
echo -e "${GREEN}🎉 Desinstalación completada${NC}"
echo ""
echo "ℹ️  Los scripts siguen en el directorio, pero ya no se ejecutan automáticamente."
echo "   Para reinstalar, ejecuta: ./install.sh"
echo ""
