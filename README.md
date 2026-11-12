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

## Layout

- `pi/` — files deployed to `/home/pi` on the Pi (`rsync -a pi/bin pi/.config pi@pidisplay.local:~/`).
  - `bin/kiosk.sh` — Chromium `--kiosk` loop, respawns on exit.
  - `.config/kiosk-url` — URL to display.
  - `.config/labwc/autostart` — launches the kiosk in the labwc (Wayland) session.
- `provisioning/` — flashing / cloud-init notes.

Screen blanking disabled via `raspi-config nonint do_blanking 1`.
- `pi/systemd/cec-wake.{service,timer}` — at boot and every 5 min, `bin/cec-wake.sh` sends CEC Image View On + Active Source to the TV on whichever HDMI port has a sink. Install: `sudo install -m644 pi/systemd/cec-wake.* /etc/systemd/system/ && sudo systemctl enable --now cec-wake.service cec-wake.timer`.

## HDMI hotplug

The current cable/monitor never asserts hotplug-detect, so `cmdline.txt` carries `video=HDMI-A-2:D` to force
the port on (modes still come from EDID). Use HDMI-A-2 = the board's second micro-HDMI (further from USB-C).
Without it the Pi sees both ports as disconnected and CEC has no physical address.
