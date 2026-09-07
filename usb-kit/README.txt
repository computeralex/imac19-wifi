2019 iMac Wi-Fi (Omarchy / Linux)
=================================

For the 21.5-inch 2019 iMac (iMac19,2) and the 27-inch 2019 iMac (iMac19,1).
No internet or ethernet needed.

On the iMac
-----------
1. Plug in this USB stick.
2. Open Files (folder icon in the dock, or Super+F).
3. Click the USB stick in the left sidebar.
4. Double-click "Install Wi-Fi".
5. Type this computer's password. Nothing will appear as you type; that is normal.
6. Press Enter when it says to shut down.
7. When the screen is black, press the power button.

If double-click opens a text file instead
-----------------------------------------
Right-click "Install Wi-Fi" -> Run as a Program
  (some versions say "Allow Launching")

Or right-click empty space in the USB window -> Open in Terminal, then type:

  sudo bash imac19-wifi-install.sh

Using the Omarchy install USB
-----------------------------
The firmware package is already on that stick (offline mirror). Copy
imac19-wifi-install.sh onto it if the stick is writable (EFI partition),
or onto any other USB. Plug the Omarchy install USB into the iMac and run
the script. It will pull apple-bcm-firmware out of the ISO.

If the Omarchy ISO is not plugged in, prepare-usb.sh can put a small
firmware folder next to this script instead.
