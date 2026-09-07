# 2019 iMac Wi-Fi for Omarchy

Wi-Fi firmware installer for the 2019 21.5-inch iMac (`iMac19,2`) and 2019 27-inch iMac (`iMac19,1`) running Omarchy.

Omarchy's install USB contains `apple-bcm-firmware` (for T2 Macs) but only **bind-mounts** that package cache during setup. It is not copied onto the installed disk, and the T2 installer never runs on these iMacs, so Wi-Fi never appears.

Do not copy files onto the Omarchy ISO stick. That image is hybrid ISO9660; writing it can break boot.

## One way

On a computer that has internet, put the installer on **any other FAT USB** (not the Omarchy ISO):

```bash
git clone https://github.com/computeralex/imac19-wifi.git
cd imac19-wifi
./prepare-usb.sh "/Volumes/YOURSTICK"
```

On a Mac you can double-click `Prepare USB.command` and pick that stick.

On the iMac: plug that stick in, open Files, double-click **Install Wi-Fi**, type the password, Enter to shut down, then power on.

```bash
sudo bash imac19-wifi-install.sh
```

If double-click opens a text file: right-click **Install Wi-Fi** -> Run as a Program.

`prepare-usb.sh` downloads the same `apple-bcm-firmware` package Arch already ships and puts a 1 MB board tarball next to the script. This repo does not store Apple's firmware.

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
