#!/usr/bin/env bash
# system-setup-power.sh — system-level power/greeter tuning.
#
# Run as root:  sudo ~/.dotfiles/scripts/system-setup-power.sh
#
# Applies:
#   1. greetd + tuigreet as the display manager (replaces SDDM at next boot)
#   2. runtime PM (autosuspend) for Ethernet + SD card reader
#   3. PCIe ASPM powersave + amd_pstate dynamic_epp (via power-tuning.service)
#   4. amdgpu ABM (panel power) via modprobe + initramfs rebuild
#   5. amd_pmf module load (optional; see warning below)
#
# --------------------------------------------------------------------------
# REVERT
#   sudo systemctl disable greetd && sudo systemctl enable sddm
#   sudo rm -f /etc/udev/rules.d/60-power-runtime-pm.rules \
#              /etc/modprobe.d/amdgpu-abm.conf \
#              /etc/modules-load.d/amd_pmf.conf \
#              /etc/systemd/system/power-tuning.service
#   sudo systemctl disable power-tuning.service
#   sudo limine-update
# --------------------------------------------------------------------------

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "must run as root: sudo $0" >&2
  exit 1
fi

say() { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. greetd + tuigreet
# ---------------------------------------------------------------------------
say "Configuring greetd + tuigreet"
if [[ -f /etc/greetd/config.toml ]]; then
  cp -a /etc/greetd/config.toml "/etc/greetd/config.toml.bak.$(date +%s)"
fi
cat > /etc/greetd/config.toml <<'EOF'
[terminal]
# The VT to run the greeter on.
vt = 1

# The default session, also known as the greeter.
[default_session]
command = "tuigreet --time --battery --remember --remember-session --asterisks --cmd /usr/bin/start-hyprland"
user = "greeter"
EOF

say "Switching display manager: disable sddm, enable greetd"
systemctl disable sddm
systemctl enable greetd
echo "display-manager.service now -> $(readlink -f /etc/systemd/system/display-manager.service)"

# ---------------------------------------------------------------------------
# 2. Runtime PM for Ethernet (01:00.0) + SD card reader (03:00.0)
# ---------------------------------------------------------------------------
say "Installing udev rule + applying runtime PM (autosuspend)"
cat > /etc/udev/rules.d/60-power-runtime-pm.rules <<'EOF'
# Allow runtime PM (autosuspend) for devices that default to always-on.
ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:01:00.0", ATTR{power/control}="auto"
ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:03:00.0", ATTR{power/control}="auto"
EOF
udevadm control --reload
udevadm trigger --subsystem-match=pci
for dev in 0000:01:00.0 0000:03:00.0; do
  echo auto > "/sys/bus/pci/devices/$dev/power/control" 2>/dev/null || true
done

# ---------------------------------------------------------------------------
# 3. amdgpu ABM (adaptive backlight / panel power)
# ---------------------------------------------------------------------------
say "Configuring amdgpu ABM (abmlevel=3)"
cat > /etc/modprobe.d/amdgpu-abm.conf <<'EOF'
options amdgpu abmlevel=3
EOF

# ---------------------------------------------------------------------------
# 4. amd_pmf module (OPTIONAL)
#    WARNING: this can change how platform_profile is handled. If power-saver
#    stops lowering CPU clocks after a reboot, remove /etc/modules-load.d/amd_pmf.conf
# ---------------------------------------------------------------------------
say "Queuing amd_pmf module at boot (optional)"
echo "amd_pmf" > /etc/modules-load.d/amd_pmf.conf

# ---------------------------------------------------------------------------
# 5. Runtime power tunings (ASPM + amd_pstate dynamic_epp)
# ---------------------------------------------------------------------------
say "Installing power-tuning.service (ASPM powersave, dynamic_epp)"
cat > /etc/systemd/system/power-tuning.service <<'EOF'
[Unit]
Description=Apply runtime power tunings (PCIe ASPM, amd_pstate dynamic_epp)
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'echo powersave > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true'
ExecStart=/bin/sh -c 'echo enabled > /sys/devices/system/cpu/amd_pstate/dynamic_epp 2>/dev/null || true'

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable power-tuning.service
echo powersave > /sys/module/pcie_aspm/parameters/policy 2>/dev/null || true
echo enabled   > /sys/devices/system/cpu/amd_pstate/dynamic_epp 2>/dev/null || true

# ---------------------------------------------------------------------------
# 6. Rebuild initramfs so amdgpu ABM applies at boot (CachyOS: limine-update)
# ---------------------------------------------------------------------------
say "Rebuilding initramfs / Limine entries"
if command -v limine-update >/dev/null 2>&1; then
  limine-update
elif command -v mkinitcpio >/dev/null 2>&1 && compgen -G '/etc/mkinitcpio.d/*.preset' >/dev/null; then
  mkinitcpio -P
else
  echo "WARN: no preset found; amdgpu ABM will only apply after the next kernel update rebuilds the initramfs." >&2
fi

say "Done. Reboot to activate greetd."
echo "Recovery if login breaks: switch to a TTY (Ctrl+Alt+F3) and run 'sudo systemctl start sddm'."
