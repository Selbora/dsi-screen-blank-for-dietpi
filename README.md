# DSI Kiosk Idle Backlight (DietPi / Raspberry Pi)

Turn a **DSI** display backlight off after a period of inactivity on a **DietPi Raspberry Pi (e.g., 3B+)** running **Chromium in kiosk mode**.

This approach does **not** rely on DPMS (often unavailable on minimal X11 kiosk setups). Instead it:
- uses `xprintidle` to measure user inactivity (keyboard/mouse/touch),
- writes to `/sys/class/backlight/.../brightness` to turn the backlight off,
- restores the previous brightness on activity,
- runs as a **systemd** service at boot.

## Requirements

- X11 session running on `:0` (common for kiosk)
- DSI backlight exposed under `/sys/class/backlight` (e.g., `rpi_backlight`)
- Packages:
  - `xprintidle`

## Quick install (recommended)

```bash
git clone <this-repo>
cd dsi-kiosk-idle-backlight
sudo ./install.sh
```

After install, the service is enabled and started.

## Configuration

Edit `kiosk-dsi-backlight-idle.sh`:

- **Idle timeout** (default 10 minutes):

```bash
IDLE_LIMIT_MS=$((10*60*1000))
```

Restart after changes:

```bash
sudo systemctl restart kiosk-dsi-backlight-idle.service
```

## Logs

```bash
journalctl -u kiosk-dsi-backlight-idle.service -f
```

## Uninstall

```bash
sudo ./uninstall.sh
```

## Notes / Troubleshooting

### No `/sys/class/backlight` entries
Your kernel/device-tree may not be exposing a backlight driver. For the official Raspberry Pi 7" DSI display, ensure the overlay is enabled in your boot config (path varies by image):

- `/boot/config.txt` **or**
- `/boot/firmware/config.txt`

Add:

```ini
dtoverlay=rpi-backlight
```

Reboot and re-check:

```bash
ls -1 /sys/class/backlight
```

### Service fails with “Permission denied”
Some systems mount `/home` with `noexec`. The provided service runs the script via bash:
`ExecStart=/bin/bash /home/dietpi/kiosk-dsi-backlight-idle.sh`
which avoids `noexec` execution issues.

If you use a different user than `dietpi`, adjust:
- `XAUTHORITY=/home/dietpi/.Xauthority`
- script/service paths as needed.

## License

MIT (see `LICENSE`).
