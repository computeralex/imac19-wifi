# 2019 iMac Wi-Fi for Omarchy

Wi-Fi does not appear after installing Omarchy on a 2019 21.5-inch or 27-inch iMac (`iMac19,2` / `iMac19,1`). This script installs the Broadcom firmware from the Omarchy ISO.

On a Mac keyboard, Super is ⌘.

## Requirements

1. Your Omarchy Quattro installation medium
2. An extra USB stick

Do not rewrite or re-flash the Omarchy installer.

## 1. Download `wifi.sh`

https://raw.githubusercontent.com/computeralex/imac19-wifi/main/wifi.sh

Copy it to the extra USB stick, top level, not inside a folder.

## 2. Drag it to Home

1. Plug in the extra stick.
2. **Super (⌘) + Shift + F** opens Files.
3. Select the USB stick in the left sidebar.
4. Drag `wifi.sh` onto **Home**.

## 3. Run it

1. **Super (⌘) + Return** opens a terminal.
2. Run:

```bash
sudo bash ~/wifi.sh
```

Enter the user password from install. sudo does not echo keystrokes.

## 4. Plug in the Omarchy installer

When the script asks, plug in the Omarchy Quattro installation medium (swap sticks if you are short on ports) and press Return.

If it cannot find the firmware package, reseat the installer and press Return again.

When it finishes, press Return to shut down. Power on after the screen goes black.

Network panel: **Super (⌘) + Ctrl + W**.

## License

MIT. Version 0.4.
