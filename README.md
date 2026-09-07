# 2019 iMac Wi-Fi for Omarchy

Offline installer for the Broadcom BCM4364 in the 2019 21.5-inch iMac (`iMac19,2`, nihau) and the 2019 27-inch iMac (`iMac19,1`, midway).

Omarchy does not ship this firmware on non-T2 iMacs, so Wi-Fi never appears. This USB kit is the workaround. No ethernet needed on the iMac.

This repo does **not** contain Apple's firmware. `prepare-usb.sh` downloads it from the existing [apple-bcm-firmware](https://github.com/NoaHimesaka1873/apple-bcm-firmware) release (the same files Arch and t2linux already use) and copies a small installer onto a USB stick.

## Prepare a stick (working Mac or Linux, needs internet)

```bash
git clone https://github.com/computeralex/imac19-wifi.git
cd imac19-wifi
chmod +x "Prepare USB.command" prepare-usb.sh
./prepare-usb.sh "/Volumes/YOURSTICK"
```

On a Mac you can double-click `Prepare USB.command` and pick the stick in the folder dialog.

## On the iMac (no internet)

1. Plug in the stick.
2. Open Files (folder icon, or Super+F).
3. Double-click **Install Wi-Fi**.
4. Type this computer's password (nothing will show as you type).
5. Press Enter to shut down.
6. When the screen is black, press the power button.

If double-click opens a text file: right-click **Install Wi-Fi** → Run as a Program (or Allow Launching).

Or open a terminal in the USB folder:

```bash
sudo bash imac19-wifi-install.sh
```

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
