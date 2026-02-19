#!/usr/bin/env bash

# Intenta cerrar Aerial y Aerial Companion de forma limpia
osascript -e 'tell application "Aerial Companion" to quit' >/dev/null 2>&1
osascript -e 'tell application "Aerial" to quit' >/dev/null 2>&1

# Por si quedan procesos colgados, intenta matarlos por nombre
killall AerialWallpaper >/dev/null 2>&1 || true
killall Aerial >/dev/null 2>&1 || true
killall "Aerial Companion" >/dev/null 2>&1 || true
