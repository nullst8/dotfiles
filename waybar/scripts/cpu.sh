#!/usr/bin/env bash
set -euo pipefail

# Instantaneous CPU usage via two /proc/stat samples.
read_cpu() {
    local line user nice system idle iowait irq softirq steal total
    line=$(grep '^cpu ' /proc/stat)
    read -r _ user nice system idle iowait irq softirq steal _ <<< "$line"
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    echo "$total $((idle + iowait))"
}

read t1 idle1 <<< "$(read_cpu)"
sleep 0.3
read t2 idle2 <<< "$(read_cpu)"

dt=$((t2 - t1))
di=$((idle2 - idle1))
usage=$(( dt > 0 ? (100 * (dt - di)) / dt : 0 ))

profile=$(powerprofilesctl get 2>/dev/null || echo "?")
case "$profile" in
    power-saver) plabel="Saver" ;;
    balanced)    plabel="Standard" ;;
    performance) plabel="Performance" ;;
    *)           plabel="$profile" ;;
esac

printf '{"text":"%s%% CPU","tooltip":"CPU %s%% · Power: %s"}\n' "$usage" "$usage" "$plabel"
