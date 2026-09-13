#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="${0:A:h}"
BUILD_DIR="$SCRIPT_DIR/build"
APP_DIR="$BUILD_DIR/Softverse Thermal Printer Emulator.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"

mkdir -p "$MACOS_DIR"

clang \
  -fobjc-arc \
  -fblocks \
  -framework Foundation \
  -framework CoreBluetooth \
  -framework IOBluetooth \
  "$SCRIPT_DIR/main.m" \
  -o "$MACOS_DIR/softverse-thermal-printer-emulator"

cp "$SCRIPT_DIR/Info.plist" "$CONTENTS_DIR/Info.plist"
codesign --force --sign - "$APP_DIR"

echo "$APP_DIR"
