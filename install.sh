#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default kiosk user (edit if needed)
KIOSK_USER="${KIOSK_USER:-dietpi}"
TARGET_SCRIPT="/home/${KIOSK_USER}/kiosk-dsi-backlight-idle.sh"
TARGET_SERVICE="/etc/systemd/system/kiosk-dsi-backlight-idle.service"

echo "[1/5] Installing dependencies..."
apt-get update -y
apt-get install -y xprintidle

echo "[2/5] Installing script to ${TARGET_SCRIPT}..."
install -m 755 "${REPO_DIR}/kiosk-dsi-backlight-idle.sh" "${TARGET_SCRIPT}"
chown "${KIOSK_USER}:${KIOSK_USER}" "${TARGET_SCRIPT}"

# Ensure unix line endings (harmless if already OK)
sed -i 's/\r$//' "${TARGET_SCRIPT}"

echo "[3/5] Installing systemd service to ${TARGET_SERVICE}..."
# Patch service file to point to the correct user/home
tmp_service="$(mktemp)"
sed "s#/home/dietpi/#/home/${KIOSK_USER}/#g" "${REPO_DIR}/kiosk-dsi-backlight-idle.service" > "${tmp_service}"
install -m 644 "${tmp_service}" "${TARGET_SERVICE}"
rm -f "${tmp_service}"

echo "[4/5] Enabling & starting service..."
systemctl daemon-reload
systemctl enable --now kiosk-dsi-backlight-idle.service

echo "[5/5] Done."
echo "Check status: systemctl status kiosk-dsi-backlight-idle.service"
echo "Follow logs : journalctl -u kiosk-dsi-backlight-idle.service -f"
