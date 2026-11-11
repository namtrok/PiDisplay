# PiDisplay

Raspberry Pi digital signage: drives a consumer TV over HDMI like a commercial display board.

## Goals

- Display a live feed / live website full-screen over HDMI (kiosk browser).
- Power-outage recovery: on boot, wake the TV and switch it to the Pi's HDMI input via HDMI-CEC (`cec-ctl` / `cec-client`).
- Unattended operation: auto-login, no screen blanking, watchdog restart of the kiosk process.
- Managed over SSH on the local network.

## Provisioning (Pi 5 via USB boot, from macOS)

1. `brew install libusb pkg-config`
2. `git clone --recurse-submodules https://github.com/raspberrypi/usbboot && cd usbboot && make`
3. Pi in USB boot mode: USB-C unplugged, hold power button, connect cable Mac→Pi, release.
4. `sudo ./rpiboot -d mass-storage-gadget64` — the Pi's storage appears on the Mac as a disk.
5. Write Raspberry Pi OS with Raspberry Pi Imager (preset user, Wi-Fi, SSH).
6. Unplug, power from the CanaKit supply, then SSH in.
