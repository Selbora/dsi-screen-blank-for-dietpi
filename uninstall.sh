#!/usr/bin/env bash
set -euo pipefail

KIOSK_USER="${KIOSK_USER:-dietpi}"
TARGET_SCRIPT="/home/${KIOSK_USER}/kiosk-dsi-backlight-idle.sh"
TARGET_SERVICE="/etc/systemd/system/kiosk-dsi-backlight-idle.service"

echo "[1/4] Stopping & disabling service (if present)..."
systemctl stop kiosk-dsi-backlight-idle.service 2>/dev/null || true
systemctl disable kiosk-dsi-backlight-idle.service 2>/dev/null || true

echo "[2/4] Removing service file..."
rm -f "${TARGET_SERVICE}"
systemctl daemon-reload

echo "[3/4] Removing script..."
rm -f "${TARGET_SCRIPT}"

echo "[4/4] Done."
