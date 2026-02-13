#!/bin/bash
# -----------------------------------------------------------
# DSI Kiosk Auto Backlight Control
# -----------------------------------------------------------
# Turns screen backlight OFF after inactivity
# Restores brightness on user activity
# Designed for DietPi + Chromium Kiosk + DSI display
# -----------------------------------------------------------

set -euo pipefail

# ---- X session access (adjust user if not 'dietpi') --------
export DISPLAY=${DISPLAY:-:0}
export XAUTHORITY=${XAUTHORITY:-/home/dietpi/.Xauthority}

# ---- Settings ---------------------------------------------
IDLE_LIMIT_MS=$((10*60*1000))   # 10 minutes (milliseconds)
SLEEP_INTERVAL=2                # seconds between checks

# ---- Backlight device discovery ---------------------------
BL_NAME="$(ls /sys/class/backlight 2>/dev/null | head -n1 || true)"
if [[ -z "${BL_NAME}" ]]; then
  echo "No backlight devices found in /sys/class/backlight"
  echo "If using the official DSI display, you may need: dtoverlay=rpi-backlight"
  exit 1
fi

BL="/sys/class/backlight/${BL_NAME}"
BRIGHTNESS="${BL}/brightness"
MAX_BRIGHTNESS="${BL}/max_brightness"

if [[ ! -r "${MAX_BRIGHTNESS}" ]]; then
  echo "Missing max_brightness: ${MAX_BRIGHTNESS}"
  exit 1
fi

MAX_VAL="$(cat "${MAX_BRIGHTNESS}")"

if [[ ! -w "${BRIGHTNESS}" ]]; then
  echo "Brightness is not writable: ${BRIGHTNESS}"
  echo "Run via systemd as root (recommended) or adjust permissions."
  exit 1
fi

STATE="on"
LAST_BRIGHTNESS="${MAX_VAL}"

# ---- Main loop --------------------------------------------
while true; do
  IDLE_TIME="$(xprintidle || echo 0)"

  # If idle beyond limit and screen is ON -> turn OFF
  if [[ "${IDLE_TIME}" -ge "${IDLE_LIMIT_MS}" && "${STATE}" == "on" ]]; then
    LAST_BRIGHTNESS="$(cat "${BRIGHTNESS}")"
    echo 0 > "${BRIGHTNESS}"
    STATE="off"
  fi

  # If activity detected and screen is OFF -> restore brightness
  if [[ "${IDLE_TIME}" -lt 1000 && "${STATE}" == "off" ]]; then
    if [[ "${LAST_BRIGHTNESS}" -le 0 ]]; then
      LAST_BRIGHTNESS="${MAX_VAL}"
    fi
    echo "${LAST_BRIGHTNESS}" > "${BRIGHTNESS}"
    STATE="on"
  fi

  sleep "${SLEEP_INTERVAL}"
done
