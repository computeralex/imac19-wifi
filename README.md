# 2019 iMac Wi-Fi for Omarchy

Offline installer for the Broadcom BCM4364 in the 2019 21.5-inch iMac (`iMac19,2`, nihau) and the 2019 27-inch iMac (`iMac19,1`, midway).

Omarchy already carries `apple-bcm-firmware` on the **install USB** (offline package mirror, for T2 Macs). It never installs that package on a 2019 iMac, so Wi-Fi never appears. This script copies the board files off that same ISO.

This repo does **not** contain Apple's firmware.

## One file

Copy `imac19-wifi-install.sh` onto a USB stick. A Balena-written Omarchy ISO is often read-only, so use the EFI partition of that stick if it is writable, or any other FAT stick.

On the iMac:

1. Plug in the Omarchy install USB (and the stick with the script, if they are different).
2. Open Files, double-click **Install Wi-Fi**, or in a terminal:

```bash
sudo bash imac19-wifi-install.sh
```

3. Type this computer's password (nothing will show as you type).
4. Press Enter to shut down. When the screen is black, press the power button.

The script looks for `apple-bcm-firmware` in the live ISO cache, then inside the install USB's squashfs (`/var/cache/omarchy/mirror/offline`). If you used `prepare-usb.sh`, it will use the small `firmware/*.tar` next to the script instead.

If double-click opens a text file: right-click **Install Wi-Fi** -> Run as a Program (or Allow Launching).

## After boot

```bash
journalctl -k --grep=brcmfmac
```

You want `Firmware: BCM4364/3`, not `Dongle setup failed`. If it still fails, swap NVRAM to the `-u` file (nihau shown):

```bash
cd /usr/lib/firmware/brcm
sudo ln -sfn brcmfmac4364b2-pcie.apple,nihau-HRPN-u.txt brcmfmac4364b2-pcie.txt
```

Then shut down fully again. Do not install `broadcom-wl` on this machine.

## Firmware

The `.bin` / NVRAM files are Apple's. They are not in git. The installer copies them off the stick to `/tmp` before extracting, because installing the full package straight from a FAT USB is what produced the truncated-archive error.
