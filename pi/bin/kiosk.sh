#!/bin/sh
# Full-screen Chromium kiosk; respawns if it exits/crashes.
URL="$(cat "$HOME/.config/kiosk-url" 2>/dev/null || echo 'https://music-command-center-rho.vercel.app/')"
PROFILE="$HOME/.cache/kiosk-profile"
while :; do
  rm -f "$PROFILE/Singleton"* 2>/dev/null
  chromium --kiosk --noerrdialogs --disable-infobars --disable-session-crashed-bubble \
    --no-first-run --password-store=basic --disable-features=TranslateUI --check-for-update-interval=31536000 \
    --ozone-platform=wayland --user-data-dir="$PROFILE" --start-fullscreen "$URL"
  sleep 3
done
