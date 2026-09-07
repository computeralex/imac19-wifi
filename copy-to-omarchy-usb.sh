#!/bin/bash
# Copy imac19-wifi-install.sh onto an Omarchy install USB without rewriting
# the ISO. Adds a small FAT32 slice in leftover space after the ISO image.
# Does not touch ISO9660 or the existing EFI boot files.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$ROOT/wifi.sh"
DESKTOP="$ROOT/usb-kit/Install Wi-Fi.desktop"
LABEL=IMACWIFI
SIZE_MB=32

[[ -f "$SCRIPT" ]] || { echo "Missing $SCRIPT"; exit 1; }

if [[ "$(uname -s)" != Darwin ]]; then
  echo "This helper is for macOS. On Linux, put the script on any FAT stick"
  echo "and plug the Omarchy ISO USB in too."
  exit 1
fi

echo "External disks:"
echo
diskutil list external
echo
echo "The Omarchy stick is the one you Balena-etched (often 8-32 GB, not a 1 TB archive drive)."
echo "We will NOT write the ISO partition. We only add a ${SIZE_MB} MB FAT32 slice"
echo "named $LABEL in unused space at the end of the stick."
echo
read -r -p "Disk identifier (e.g. disk9): " DISK
DISK="${DISK#/dev/}"
[[ "$DISK" == disk* ]] || { echo "Expected diskN"; exit 1; }

WHOLE="/dev/$DISK"
diskutil info "$WHOLE" | grep -E 'Device / Media Name|Disk Size|Protocol|Content' || true
echo
diskutil list "$WHOLE"
echo
read -r -p "Type YES to add $LABEL and copy the installer: " OK
[[ "$OK" == YES ]] || { echo "Aborted."; exit 1; }

# Refuse if this looks like an internal or huge archive disk.
SIZE_B=$(diskutil info "$WHOLE" | awk -F'[()]' '/Disk Size/ {print $2; exit}' | awk '{print $1}')
if [[ -n "${SIZE_B:-}" ]] && (( SIZE_B > 128*1024*1024*1024 )); then
  echo "That disk is larger than 128 GB. Refusing so we do not touch archive drives."
  exit 1
fi

if diskutil info "$WHOLE" | grep -q 'Protocol:.*SATA\|Protocol:.*PCI'; then
  echo "That does not look like USB. Refusing."
  exit 1
fi

# Map current partitions so we can see free space.
gpt_show=$(sudo gpt -r show "$WHOLE")
echo "$gpt_show"

if diskutil list "$WHOLE" | grep -qi "$LABEL"; then
  echo "A $LABEL volume already exists. Copying onto it."
else
  # diskutil addPartition against the last slice, into trailing free space.
  last=$(diskutil list "$WHOLE" | awk '/^ *[0-9]+:/ {id=$NF} END {print id}')
  [[ -n "$last" && "$last" == ${DISK}s* ]] || { echo "Could not find a slice to extend after."; exit 1; }
  echo "Adding ${SIZE_MB}m FAT32 after $last..."
  sudo diskutil addPartition "$last" FAT32 "$LABEL" "${SIZE_MB}M"
fi

# Mount whatever slice now carries the label.
VOL="/Volumes/$LABEL"
if [[ ! -d "$VOL" ]]; then
  slice=$(diskutil list "$WHOLE" | awk -v L="$LABEL" 'tolower($0) ~ tolower(L) {print $NF; exit}')
  [[ -n "${slice:-}" ]] || { echo "Created the partition but could not find it."; exit 1; }
  sudo diskutil mount "/dev/$slice"
fi

[[ -d "$VOL" ]] || { echo "Could not mount $LABEL"; exit 1; }

mkdir -p "$VOL"
cp "$SCRIPT" "$VOL/wifi.sh"
chmod +x "$VOL/wifi.sh" || true
sync
diskutil unmount "$VOL" || true

echo
echo "Done. The Omarchy ISO and EFI boot files were not rewritten."
echo "On the iMac: drag wifi.sh to Home, then: sudo bash ~/wifi.sh"
