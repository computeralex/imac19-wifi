#!/bin/bash
# Offline Wi-Fi firmware for 2019 iMac (iMac19,2 21.5" and iMac19,1 27").
# Safe to run from a FAT USB: copies the archive off the stick, then extracts.
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

HERE="$(cd "$(dirname "$0")" && pwd)"
MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo unknown)"
FW=/usr/lib/firmware/brcm

case "$MODEL" in
  iMac19,2) BOARD=nihau; PRETTY="2019 21.5-inch iMac" ;;
  iMac19,1) BOARD=midway; PRETTY="2019 27-inch iMac" ;;
  *)
    echo
    echo "  This computer reports as: $MODEL"
    echo "  This installer is for 2019 iMacs (iMac19,2 / iMac19,1) only."
    echo
    read -r -p "  Press Enter to close."
    exit 1
    ;;
esac

TAR="$HERE/firmware/${BOARD}.tar"
if [[ ! -f "$TAR" ]]; then
  echo "  Missing $TAR"
  echo "  Copy the whole usb-kit folder onto the stick (including firmware/)."
  read -r -p "  Press Enter to close."
  exit 1
fi

echo
echo "  Installing Wi-Fi firmware for ${PRETTY} (${MODEL}, ${BOARD})"
echo

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
cp "$TAR" "$WORK/firmware.tar"
mkdir -p "$FW"
tar -xf "$WORK/firmware.tar" -C /

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
