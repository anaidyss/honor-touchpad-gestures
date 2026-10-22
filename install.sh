#!/bin/sh
set -e
cd "$(dirname "$0")"

install -Dm755 touchpad-gestures "$HOME/.local/bin/touchpad-gestures"
install -Dm644 touchpad-gestures.service "$HOME/.config/systemd/user/touchpad-gestures.service"

sudo install -m644 70-touchpad-gestures.rules /etc/udev/rules.d/70-touchpad-gestures.rules
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=input --subsystem-match=hidraw --action=change

systemctl --user daemon-reload
systemctl --user enable --now touchpad-gestures.service
systemctl --user restart touchpad-gestures.service
echo "done: systemctl --user status touchpad-gestures"
