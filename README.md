# 2019 iMac Wi-Fi for Omarchy

You installed Omarchy on a 2019 iMac. Wi-Fi does not show up. That is expected.

Keep this where you can see it if you cannot memorize it. The iMac cannot load this page until Wi-Fi works.

On a Mac keyboard, **Super** is the Command key (next to the spacebar).

## 1. Download the file

https://raw.githubusercontent.com/computeralex/imac19-wifi/main/wifi

Your browser will probably save it as `wifi.txt`. That is fine. Put it on a USB stick, top level, not in a folder.

You also need the USB stick you used to **install Omarchy**. Do not rewrite that one.

## 2. Drag it to Home

1. Plug in the stick that has `wifi.txt`.
2. Press **Command + Shift + F**. Files opens.
3. Click the USB stick in the left sidebar.
4. Drag `wifi.txt` onto **Home** (the house icon).

## 3. Run it

1. Press **Command + Return**. A terminal opens.
2. Type this and press Return:

```bash
sudo bash ~/wifi.txt
```

If the file has no `.txt`, leave `.txt` off that command.

Type the password you chose at install. Nothing will appear as you type. Press Return.

## 4. Plug in the Omarchy installer USB

When it asks, unplug the first stick if you need the port, plug in the **Omarchy installer** USB, press Return.

If it cannot find it, try another port and press Return again.

When it says done, press Return. The iMac shuts down. Screen black, then press the power button.

Wi-Fi: **Command + Ctrl + W**.
