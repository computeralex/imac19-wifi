# 2019 iMac Wi-Fi for Omarchy

You installed Omarchy on a 2019 iMac. Wi-Fi does not show up. That is expected.

Keep this page on your phone. The iMac cannot load it until Wi-Fi works.

## What you need

- This computer (or your phone) with internet
- The USB stick you used to **install Omarchy**. Do not rewrite it or format it
- A second USB stick or SD card, to carry one file to the iMac

## 1. Download the installer

On this computer, download:

https://raw.githubusercontent.com/computeralex/imac19-wifi/main/imac19-wifi-install.sh

Save it onto the second USB stick. The file name should stay `imac19-wifi-install.sh`. Put it in the top level of the stick, not inside a folder.

## 2. On the iMac, open a terminal

On a Mac keyboard, **Super** is the Command key (the one with the loop, next to the spacebar).

1. Plug in the second USB stick (the one with the script).
2. Press **Command + Return** (that's Super + Return). A terminal window opens.

## 3. Run this command

Type this line and press Return. Spaces and slashes matter:

```bash
sudo bash $(find /run/media /media /mnt -name imac19-wifi-install.sh -print -quit)
```

It will ask for **this computer's password** (the one you chose during the Omarchy install). Nothing will appear as you type. That is normal. Press Return when you are done.

## 4. Plug in the Omarchy installer

The script will say it needs the USB stick you installed Omarchy from.

1. Unplug the second stick if you are short on ports.
2. Plug in the **Omarchy installer** USB.
3. Press Return.

If it says it could not find it, the installer is not seated. Try another port and press Return again.

## 5. Shut down

When it says it is done, press Return. The iMac will shut down fully.

When the screen is black, press the power button. After it comes up, Wi-Fi should appear (Command + Ctrl + W opens the network panel).

## If the command says "No such file"

The script is not on the stick, or it is nested in a folder. Put `imac19-wifi-install.sh` in the top level of the second stick and try step 3 again.

Files is **Command + Shift + F**. The USB shows up in the left sidebar. That is only to check the file is there. Running it still happens in the terminal.

## If Wi-Fi still does not appear

In a terminal:

```bash
journalctl -k --grep=brcmfmac
```

You want `Firmware: BCM4364/3`, not `Dongle setup failed`. Do not install `broadcom-wl`.
