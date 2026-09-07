#!/bin/bash
# Wi-Fi installer for 2019 iMacs on Omarchy (iMac19,2 / iMac19,1).
# Version 0.4
# Drag this file to Home, then: sudo bash ~/wifi.sh
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
  if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    cmd=(bash "$0")
    for term in xdg-terminal-exec ghostty kitty alacritty gnome-terminal kgx konsole xfce4-terminal xterm; do
      if command -v "$term" >/dev/null 2>&1; then
        case "$term" in
          xdg-terminal-exec) exec "$term" sudo "${cmd[@]}" ;;
          gnome-terminal|kgx) exec "$term" -- sudo "${cmd[@]}" ;;
          xfce4-terminal) exec "$term" -e "sudo bash $0" ;;
          *) exec "$term" -e sudo "${cmd[@]}" ;;
        esac
      fi
    done
  fi
  echo
  echo "  2019 iMac Wi-Fi installer"
  echo "  Password for this computer:"
  echo
  exec sudo -k bash "$0" "$@"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "${IMAC19_WIFI_REEXEC:-}" != 1 ]]; then
  cp "$0" /tmp/imac19-wifi-install.sh
  rm -rf /tmp/imac19-wifi-kit
  mkdir -p /tmp/imac19-wifi-kit
  if [[ -d "$SRC_DIR/firmware" ]]; then
    cp -a "$SRC_DIR/firmware" /tmp/imac19-wifi-kit/firmware
  fi
  export IMAC19_WIFI_REEXEC=1
  exec bash /tmp/imac19-wifi-install.sh
fi
HERE=/tmp/imac19-wifi-kit

MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo unknown)"
FW=/usr/lib/firmware/brcm
WORK="$(mktemp -d)"
MOUNTS=()

unmount_scans() {
  local m
  for m in "${MOUNTS[@]+"${MOUNTS[@]}"}"; do
    umount "$m" 2>/dev/null || true
  done
  MOUNTS=()
}

cleanup() {
  unmount_scans
  rm -rf "$WORK"
}
trap cleanup EXIT

die() {
  echo
  echo "  $*"
  echo
  read -r -p "  Press Enter to close."
  exit 1
}

case "$MODEL" in
  iMac19,2) BOARD=nihau; PRETTY="2019 21.5-inch iMac" ;;
  iMac19,1) BOARD=midway; PRETTY="2019 27-inch iMac" ;;
  *) die "This computer reports as: $MODEL. This installer is for 2019 iMacs only." ;;
esac

find_pkg_in() {
  local dir=$1
  [[ -d "$dir" ]] || return 1
  find "$dir" -name 'apple-bcm-firmware-*.pkg.tar.zst' -print -quit 2>/dev/null
}

mount_ro() {
  local src=$1 dest=$2
  shift 2
  mkdir -p "$dest"
  if mount -o ro "$@" "$src" "$dest" 2>/dev/null; then
    MOUNTS+=("$dest")
    return 0
  fi
  return 1
}

find_sfs() {
  local root=$1
  find "$root" -name 'airootfs.sfs' -print -quit 2>/dev/null
}

pkg_from_sfs() {
  local sfs=$1
  local mnt="$WORK/sfs"
  mount_ro "$sfs" "$mnt" -t squashfs -o loop || return 1
  find_pkg_in "$mnt/var/cache/omarchy/mirror/offline"
}

scan_iso_device() {
  local dev=$1
  local mnt="$WORK/iso-${dev##*/}"
  mount_ro "$dev" "$mnt" || return 1
  local pkg sfs
  pkg="$(find_pkg_in "$mnt" || true)"
  [[ -n "${pkg:-}" ]] && { printf '%s\n' "$pkg"; return 0; }
  sfs="$(find_sfs "$mnt" || true)"
  [[ -n "${sfs:-}" ]] && pkg_from_sfs "$sfs"
}

find_apple_pkg() {
  local pkg sfs dev fstype

  shopt -s nullglob
  for pkg in /var/cache/omarchy/mirror/offline/apple-bcm-firmware-*.pkg.tar.zst; do
    printf '%s\n' "$pkg"
    return 0
  done
  shopt -u nullglob

  for pkg in \
    "$(find_pkg_in /run/media || true)" \
    "$(find_pkg_in /media || true)" \
    "$(find_pkg_in /mnt || true)" \
    "$(find_pkg_in /run/archiso || true)"
  do
    [[ -n "$pkg" ]] && { printf '%s\n' "$pkg"; return 0; }
  done

  for sfs in \
    "$(find_sfs /run/media || true)" \
    "$(find_sfs /media || true)" \
    "$(find_sfs /mnt || true)" \
    "$(find_sfs /run/archiso || true)"
  do
    [[ -n "$sfs" ]] || continue
    pkg="$(pkg_from_sfs "$sfs" || true)"
    [[ -n "${pkg:-}" ]] && { printf '%s\n' "$pkg"; return 0; }
  done

  if command -v lsblk >/dev/null 2>&1; then
    while read -r dev fstype; do
      [[ "$fstype" == iso9660 || "$fstype" == udf ]] || continue
      pkg="$(scan_iso_device "$dev" || true)"
      [[ -n "${pkg:-}" ]] && { printf '%s\n' "$pkg"; return 0; }
    done < <(lsblk -nrpo NAME,FSTYPE)
  fi
  return 1
}

install_from_brcm_dir() {
  local src=$1
  local f
  mkdir -p "$FW"
  for f in \
    "brcmfmac4364b2-pcie.apple,${BOARD}.bin" \
    "brcmfmac4364b2-pcie.apple,${BOARD}.clm_blob" \
    "brcmfmac4364b2-pcie.apple,${BOARD}.txcap_blob" \
    "brcmfmac4364b2-pcie.apple,${BOARD}-HRPN-m.txt" \
    "brcmfmac4364b2-pcie.apple,${BOARD}-HRPN-u.txt"
  do
    [[ -e "$src/$f" ]] || die "Firmware file missing in package: $f"
    cp -L "$src/$f" "$FW/$f"
  done
}

echo
echo "  Installing Wi-Fi firmware for ${PRETTY} (${MODEL}, ${BOARD})"
echo

TAR="$HERE/firmware/${BOARD}.tar"
if [[ -f "$TAR" ]]; then
  echo "  Using $TAR"
  mkdir -p "$WORK/from-tar"
  tar -xf "$TAR" -C "$WORK/from-tar"
  install_from_brcm_dir "$WORK/from-tar/usr/lib/firmware/brcm"
else
  echo "  Need the USB stick you used to install Omarchy."
  echo "  Plug it in now (you can unplug the stick that has this script)."
  echo
  PKG=""
  while [[ -z "${PKG:-}" ]]; do
    read -r -p "  Press Enter when the Omarchy installer USB is plugged in..."
    unmount_scans
    echo "  Looking..."
    PKG="$(find_apple_pkg || true)"
    if [[ -z "${PKG:-}" ]]; then
      echo
      echo "  Could not find it. Use the same stick you installed Omarchy from."
      echo
    fi
  done
  echo "  Found $PKG"
  mkdir -p "$WORK/pkg"
  if tar --zstd -xf "$PKG" -C "$WORK/pkg" 2>/dev/null; then
    :
  else
    tar -xf "$PKG" -C "$WORK/pkg"
  fi
  install_from_brcm_dir "$WORK/pkg/usr/lib/firmware/brcm"
fi

cd "$FW"
ln -sfn "brcmfmac4364b2-pcie.apple,${BOARD}-HRPN-m.txt" "brcmfmac4364b2-pcie.txt"
ln -sfn "brcmfmac4364b2-pcie.apple,${BOARD}-HRPN-m.txt" "brcmfmac4364b2-pcie.apple,${BOARD}.txt"
ln -sfn "brcmfmac4364b2-pcie.apple,${BOARD}.txcap_blob" "brcmfmac4364b2-pcie.txcap_blob"
ln -sfn "brcmfmac4364b2-pcie.apple,${BOARD}.bin" "brcmfmac4364b2-pcie.bin"
ln -sfn "brcmfmac4364b2-pcie.apple,${BOARD}.clm_blob" "brcmfmac4364b2-pcie.clm_blob"

mkdir -p /etc/modprobe.d
if [[ ! -f /etc/modprobe.d/brcmfmac.conf ]]; then
  printf '%s\n' 'options brcmfmac feature_disable=0x82000' > /etc/modprobe.d/brcmfmac.conf
fi

sync

echo "  Done."
echo
echo "  The computer must shut down fully (not restart)."
echo "  After the screen goes black, press the power button."
echo
read -r -p "  Press Enter to shut down now."
shutdown -h now
