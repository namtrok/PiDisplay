#!/bin/sh
# Wake the display over HDMI-CEC and switch it to this input. Run at boot and periodically.
# Uses whichever CEC adapter has a valid physical address (i.e. the connected HDMI port).
for dev in /dev/cec1 /dev/cec0; do
  [ -e "$dev" ] || continue
  cec-ctl -d "$dev" --playback -S >/dev/null 2>&1
  pa=$(cec-ctl -d "$dev" -S 2>/dev/null | sed -n 's/.*Physical Address *: *//p' | head -1)
  [ -n "$pa" ] && [ "$pa" != "f.f.f.f" ] || continue
  cec-ctl -d "$dev" --to 0 --image-view-on
  cec-ctl -d "$dev" --to 0 --active-source phys-addr="$pa"
  exit 0
done
echo "cec-wake: no HDMI sink with a physical address" >&2
exit 0
