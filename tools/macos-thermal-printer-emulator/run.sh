#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
APP_DIR="$SCRIPT_DIR/build/Softverse Thermal Printer Emulator.app"
CAPTURE_DIR="$SCRIPT_DIR/captures"

if [[ ! -x "$APP_DIR/Contents/MacOS/softverse-thermal-printer-emulator" ]]; then
  "$SCRIPT_DIR/build.sh"
fi

mkdir -p "$CAPTURE_DIR"
exec "$APP_DIR/Contents/MacOS/softverse-thermal-printer-emulator" \
  --output "$CAPTURE_DIR"
