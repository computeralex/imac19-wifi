#!/bin/bash
# Fetch Apple BCM4364 board files and copy the installer onto a USB stick.
# Firmware is not stored in this repo; it is downloaded from the existing
# apple-bcm-firmware release (same files Arch / t2linux already ship).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
CACHE="$ROOT/.firmware-cache"
EXTRACT="$CACHE/extracted"
PKG_NAME="apple-bcm-firmware-14.0-1-any.pkg.tar.zst"
URL="https://github.com/NoaHimesaka1873/apple-bcm-firmware/releases/download/v14.0/${PKG_NAME}"
PKG="$CACHE/$PKG_NAME"
KIT="$ROOT/usb-kit"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Need $1 on PATH."
    exit 1
  }
}

need curl
need tar

untar_zst() {
  local src=$1 dest=$2
  shift 2
  if tar --zstd -tf "$src" >/dev/null 2>&1; then
    tar --zstd -xf "$src" -C "$dest" "$@"
  elif command -v zstd >/dev/null 2>&1; then
    zstd -d -c "$src" | tar -xf - -C "$dest" "$@"
  else
    echo "Need tar --zstd or zstd to unpack the firmware package."
    exit 1
  fi
}

fetch_firmware() {
  mkdir -p "$CACHE" "$EXTRACT" "$KIT/firmware"
  if [[ ! -f "$PKG" ]]; then
    echo "Downloading firmware package..."
    curl -L --fail --progress-bar -o "$PKG.partial" "$URL"
    mv "$PKG.partial" "$PKG"
  fi
  echo "Unpacking firmware package..."
  rm -rf "$EXTRACT"
  mkdir -p "$EXTRACT"
  # Full extract: nihau.bin is a hard link to ekans.bin in the upstream package.
  untar_zst "$PKG" "$EXTRACT"
  BRCM="$EXTRACT/usr/lib/firmware/brcm"
  for board in nihau midway; do
    echo "Packing ${board}..."
    stage="$CACHE/stage-${board}"
    rm -rf "$stage"
    mkdir -p "$stage/usr/lib/firmware/brcm"
    for f in \
      "brcmfmac4364b2-pcie.apple,${board}.bin" \
      "brcmfmac4364b2-pcie.apple,${board}.clm_blob" \
      "brcmfmac4364b2-pcie.apple,${board}.txcap_blob" \
      "brcmfmac4364b2-pcie.apple,${board}-HRPN-m.txt" \
      "brcmfmac4364b2-pcie.apple,${board}-HRPN-u.txt"
    do
      cp -L "$BRCM/$f" "$stage/usr/lib/firmware/brcm/"
    done
    tar -C "$stage" -cf "$KIT/firmware/${board}.tar" usr/lib/firmware/brcm
  done
}

copy_kit() {
  local dest=$1
  [[ -d "$dest" ]] || {
    echo "Not a folder: $dest"
    exit 1
  }
  [[ -f "$KIT/firmware/nihau.tar" ]] || fetch_firmware
  mkdir -p "$dest/firmware"
  cp "$KIT/imac19-wifi-install.sh" "$dest/"
  cp "$KIT/Install Wi-Fi.desktop" "$dest/"
  cp "$KIT/README.txt" "$dest/"
  cp "$KIT/firmware/nihau.tar" "$KIT/firmware/midway.tar" "$dest/firmware/"
  chmod +x "$dest/imac19-wifi-install.sh" || true
  echo "Copied installer to $dest"
  echo "Eject the stick, plug it into the iMac, open Files, double-click Install Wi-Fi."
}

DEST="${1:-}"
if [[ -z "$DEST" ]]; then
  echo "Usage: ./prepare-usb.sh /path/to/usb-stick"
  echo "Example: ./prepare-usb.sh \"/Volumes/NO NAME\""
  fetch_firmware
  echo "Firmware packed in usb-kit/firmware/. Pass a USB path to copy it."
  exit 0
fi

fetch_firmware
copy_kit "$DEST"
