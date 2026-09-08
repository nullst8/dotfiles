#!/usr/bin/env bash
# Custom pulseaudio module for waybar.
# Replicates the native pulseaudio module (volume%, device icon, bluetooth
# format, muted state) and extends the tooltip with the bluetooth device
# battery percentage: "name_of_device (battery %)".

set -euo pipefail

CACHE_TTL=60
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_FILE="$CACHE_DIR/waybar-bt-battery"

# Icon glyphs (same codepoints as the previous native module config)
printf -v ICON_MUTE '\uf026'
printf -v ICON_LOW '\uf026'
printf -v ICON_MID '\uf027'
printf -v ICON_HIGH '\uf028'
printf -v ICON_HEADPHONE '\uf025'
printf -v ICON_HEADSET '\U000F02CE'
printf -v ICON_PHONE '\uf095'
printf -v ICON_CAR '\uf1b9'
printf -v ICON_BT '\uf294'

volinfo=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || exit 0
muted=0
[[ $volinfo == *MUTED* ]] && muted=1
volf=${volinfo//[!0-9.]/}
pct=$(awk -v v="$volf" 'BEGIN{printf "%.0f", v*100}')

sink=$(pactl get-default-sink 2>/dev/null) || exit 0

# name, desc, active port, form factor, bt address (tab separated)
IFS=$'\t' read -r name desc port ff addr < <(
  pactl -f json list sinks 2>/dev/null | python3 -c '
import json, sys
default = sys.argv[1]
for s in json.load(sys.stdin):
    if s["name"] == default:
        p = s["properties"]
        print("\t".join([
            s["name"], s["description"], s.get("active_port") or "",
            p.get("device.form_factor") or "", p.get("api.bluez5.address") or "",
        ]))
        break
' "$sink"
)
[[ -n ${name:-} ]] || exit 0

is_bt=0
[[ $name == bluez* ]] && is_bt=1

if ((muted)); then
  icon=$ICON_MUTE
else
  # Same port matching order as waybar's native module
  needle=$(printf '%s%s' "$port" "$ff" | tr '[:upper:]' '[:lower:]')
  key=""
  for p in headphone speaker hdmi headset hands-free portable car hifi phone; do
    if [[ $needle == *"$p"* ]]; then
      key=$p
      break
    fi
  done
  case $key in
    headphone) icon=$ICON_HEADPHONE ;;
    headset | hands-free) icon=$ICON_HEADSET ;;
    phone | portable) icon=$ICON_PHONE ;;
    car) icon=$ICON_CAR ;;
    *) # no icon defined for this port -> default volume-scaled icon
      idx=$((pct / 33))
      ((idx > 2)) && idx=2
      case $idx in
        0) icon=$ICON_LOW ;;
        1) icon=$ICON_MID ;;
        2) icon=$ICON_HIGH ;;
      esac
      ;;
  esac
fi

if ((muted)); then
  text=$icon
elif ((is_bt)); then
  text="${pct}% $icon$ICON_BT"
else
  text="${pct}% $icon"
fi

class=""
((muted)) && class=muted

get_battery() {
  local mac=$1 now pct c_mac c_time c_pct
  now=$(date +%s)
  if [[ -f $CACHE_FILE ]]; then
    IFS=' ' read -r c_mac c_time c_pct < "$CACHE_FILE" || true
    if [[ ${c_mac:-} == "$mac" && $((now - ${c_time:-0})) -lt $CACHE_TTL ]]; then
      printf '%s' "${c_pct:-}"
      return
    fi
  fi
  pct=$(bluetoothctl info "$mac" 2>/dev/null |
    grep -oP 'Battery Percentage:.*\(\K[0-9]+' || true)
  printf '%s %s %s\n' "$mac" "$now" "$pct" > "$CACHE_FILE" 2>/dev/null || true
  printf '%s' "$pct"
}

tooltip=$desc
if ((is_bt)) && [[ -n ${addr:-} ]]; then
  batt=$(get_battery "$addr")
  [[ -n $batt ]] && tooltip="$desc ($batt%)"
fi

python3 - "$text" "$tooltip" "$class" <<'PY'
import json, sys
print(json.dumps({
    "text": sys.argv[1],
    "tooltip": sys.argv[2],
    "class": sys.argv[3],
}))
PY
