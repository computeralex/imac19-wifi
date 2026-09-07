# 2019 iMac Wi-Fi for Omarchy

You installed Omarchy on a 2019 iMac. Wi-Fi does not show up. That is expected.

The installer USB still has the firmware (it is there for T2 Macs). Omarchy never copies it onto the disk, and it never installs it on this iMac.

## What you need

1. Another computer with internet (the one you are reading this on).
2. The USB stick you used to **install Omarchy**. Do not rewrite it.
3. Any way to get one file onto the iMac (another USB stick, SD card, whatever).

## On this computer

Download [imac19-wifi-install.sh](https://raw.githubusercontent.com/computeralex/imac19-wifi/main/imac19-wifi-install.sh) and copy it onto a USB stick that is **not** the Omarchy installer.

## On the iMac

1. Plug in the stick that has `imac19-wifi-install.sh`.
2. Open Files, then a terminal in that folder, and run:

```bash
sudo bash imac19-wifi-install.sh
```

3. When it asks, plug in the Omarchy **installer** USB (you can swap sticks) and press Enter.
4. Type this computer's password. Nothing will show as you type.
5. Press Enter to shut down. When the screen is black, press the power button.

If double-clicking **Install Wi-Fi** works, that is the same script. If it opens as text, right-click -> Run as a Program.

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
