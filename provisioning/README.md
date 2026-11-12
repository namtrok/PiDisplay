# Provisioning notes

Image: `2026-10-06-raspios-trixie-arm64.img.xz` (Raspberry Pi OS Desktop 64-bit, Trixie).
Trixie uses cloud-init (NoCloud, seeded from `/boot/firmware`): customisation goes in
`user-data` and `network-config` on the `bootfs` partition, not `firstrun.sh`/`custom.toml`.

## Flash from macOS via the Pi's own slot (no card reader needed)

```
cd ~/projects/usbboot && sudo ./rpiboot -d mass-storage-gadget64   # start first, leave waiting
# Pi: USB-C unplugged → hold power button → connect Mac→Pi USB-C → release
diskutil list external physical                                     # find diskN (mmcblk0)
diskutil unmountDisk /dev/diskN
xzcat os.img.xz | sudo dd of=/dev/rdiskN bs=4m status=progress
diskutil mountDisk /dev/diskN                                       # /Volumes/bootfs
```

Write `user-data` / `network-config` (templates below), `diskutil unmountDisk`, unplug, power from the PSU.

Gotchas hit:
- rpiboot prints the Compute Module "fit the nRPIBOOT jumper" hint while waiting; on a Pi 5 it's the power-button trick, no jumper.
- A charge-only USB-C cable never enumerates. Use a data cable.
- Gadget with no SD card inserted shows a LUN with no medium (no disk node on the Mac).

## user-data (secrets redacted)

```yaml
#cloud-config
hostname: pidisplay
manage_etc_hosts: true
packages: [avahi-daemon]
timezone: America/New_York
keyboard: {model: pc105, layout: us}
user:
  name: pi
  shell: /bin/bash
  lock_passwd: false
  passwd: <openssl passwd -6>
  ssh_authorized_keys: [<~/.ssh/id_ed25519.pub>]
  sudo: ALL=(ALL) NOPASSWD:ALL
ssh_pwauth: false
runcmd:
  - [ systemctl, enable, --now, ssh ]
```

## network-config

```yaml
network:
  version: 2
  ethernets: {eth0: {dhcp4: true, optional: true}}
  wifis:
    wlan0:
      dhcp4: true
      optional: true
      regulatory-domain: US
      access-points:
        "<ssid>": {password: "<psk>"}
```

Access: `ssh pi@pidisplay.local` (key only).
