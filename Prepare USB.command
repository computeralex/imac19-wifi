#!/bin/bash
# Double-click this on a Mac that has internet. It fills a USB stick.
cd "$(dirname "$0")"
set -euo pipefail

DEST="$(osascript -e 'tell application "Finder"
  POSIX path of (choose folder with prompt "Choose the USB stick to put the iMac Wi-Fi installer on")
end tell' 2>/dev/null || true)"

if [[ -z "${DEST:-}" ]]; then
  echo "No folder chosen."
  read -r -p "Press Enter to close."
  exit 1
fi

./prepare-usb.sh "$DEST"
echo
read -r -p "Press Enter to close."
