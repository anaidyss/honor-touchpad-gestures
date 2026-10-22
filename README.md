# honor-touchpad-gestures

Touchpad gestures for the **Honor MagicBook Art 14** (touchpad `TOPS0102:00 35CC:0104`) on Linux.
Written and tested on Fedora with niri (Wayland); nothing in it is compositor-specific except the
OSD, which uses [`swayosd-client`](https://github.com/ErikReider/SwayOSD).

| Gesture | Action |
|---|---|
| Slide along the **right edge** | volume up / down (3% per step) |
| Slide along the **left edge** | brightness up / down (3% per step) |
| Two-finger **click** or quick two-finger **tap** | double click |

The edge vibration is still produced by the touchpad firmware, as on Windows.

## How it works

The touchpad is a standard Windows Precision Touchpad, but its firmware also detects edge slides on its
own. It reports them on a vendor HID channel (report ID 14) that neither the kernel nor libinput uses:

```
0e SS DD    SS: 04 = right edge, 03 = left edge     DD: 01 = up, 02 = down
```

One packet is sent about every 100 ms while the finger slides. The firmware also drops the normal
touch contact after about 8 mm of edge travel, so tracking finger coordinates cannot work for this;
the vendor reports are the only reliable source.

`touchpad-gestures` (Python, `python-evdev`):

1. reads those reports from `/dev/hidraw*` and calls `swayosd-client --output-volume / --brightness`;
2. grabs the touchpad and re-emits it through a uinput clone, hiding touches that start in the outer 5%
   of the pad (so edge slides do not move the cursor) and turning two-finger clicks/taps into double clicks
   through a virtual mouse.

If the service stops, the grab is released and the touchpad goes back to normal.

## Install

Requires `python-evdev`, `swayosd` (server running) and systemd.

```sh
./install.sh
```

This installs the script, a user service, and a udev rule that gives the logged-in user access to the
touchpad's evdev and hidraw nodes (`uaccess`, no `input` group needed).

## Tuning

Constants at the top of `touchpad-gestures`: `STEP_PERCENT`, `EDGE_FRAC`, `TAP_MAX_S`, `TAP_MOVE_FRAC`,
`EDGE_ACTIONS` (swap sides). Other hardware: change `HID_ID` in the script and the names/IDs in the
udev rule; the report format will most likely differ.

---

## По-русски

Жесты тачпада для Honor MagicBook Art 14 под Linux: свайп по правому краю меняет громкость, по левому
яркость, клик или тап двумя пальцами даёт двойной клик. Вибрацию по краю, как и в Windows, делает сама
прошивка тачпада. Прошивка отдаёт краевые свайпы отдельным вендорским отчётом HID (id 14), поэтому
сервис читает его из `hidraw`, а не считает координаты. Установка: `./install.sh`.
