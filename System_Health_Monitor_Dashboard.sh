#!/bin/bash

# === CONFIGURATION ===
REFRESH_RATE=3
FILTER="all"
LOG_FILE="health_alerts.log"

# === COLOR CODES ===
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

# === DRAW USAGE BARS ===
draw_bar() {
    local percent=$1
    local status=$2
    local bar=""
    for i in $(seq 1 50); do
        if (( i <= percent / 2 )); then
            case "$status" in
                OK) bar+="${GREEN}█";;
                WARNING) bar+="${YELLOW}█";;
                CRITICAL) bar+="${RED}█";;
            esac
        else
            bar+="${NC}░"
        fi
    done
    echo -e "$bar${NC}"
}

get_status() {
    local value=$1
    local warn=$2
    local crit=$3
    if (( value >= crit )); then echo "CRITICAL"
    elif (( value >= warn )); then echo "WARNING"
    else echo "OK"; fi
}

log_alert() {
    local message=$1
    echo "[$(date +%T)] $message" >> "$LOG_FILE"
}

# === DASHBOARD ===
draw_dashboard() {
    clear
    echo -e "╔════════════ SYSTEM HEALTH MONITOR v1.0 ════════════╗  [R]efresh rate: ${REFRESH_RATE}s"
    echo -e "║ Hostname: $(hostname)          Date: $(date +%F) ║  [F]ilter: ${FILTER^^}"
    echo -e "║ Uptime: $(uptime -p | cut -d' ' -f2-) ║  [Q]uit"
    echo -e "╚═══════════════════════════════════════════════════════════════════════╝"

    # === CPU ===
    cpu_idle=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | cut -d. -f1)
    cpu_usage=$((100 - cpu_idle))
    cpu_status=$(get_status $cpu_usage 60 80)
    [[ $cpu_status != OK ]] && log_alert "CPU usage exceeded threshold (${cpu_usage}%)"
    echo -en "CPU USAGE: ${cpu_usage}% "
    draw_bar $cpu_usage $cpu_status
    echo -e "  Status: [$cpu_status]"

    # Top 3 CPU processes
    ps -eo comm,%cpu --sort=-%cpu | head -n 4 | tail -n 3 | awk '{printf "  Process: %s (%s%%)\n", $1, $2}'

    # === MEMORY ===
    read -r mem_total mem_used mem_free <<< $(free -m | awk '/Mem:/ {print $2, $3, $4}')
    mem_percent=$(( 100 * mem_used / mem_total ))
    mem_status=$(get_status $mem_percent 60 75)
    [[ $mem_status != OK ]] && log_alert "Memory usage exceeded threshold (${mem_percent}%)"
    echo -en "MEMORY: ${mem_used}MB/${mem_total}MB (${mem_percent}%) "
    draw_bar $mem_percent $mem_status
    echo -e "  Status: [$mem_status]"
    echo "  Free: ${mem_free}MB"

    # === DISK ===
    echo -e "\nDISK USAGE:"
    df -h --output=target,pcent | grep -v "Mounted" | while read mount usage; do
        percent=$(echo $usage | tr -d '%')
        status=$(get_status $percent 60 75)
        [[ $status != OK ]] && log_alert "Disk usage on $mount exceeded threshold (${percent}%)"
        echo -en "  $mount : ${percent}% "
        draw_bar $percent $status
        echo -e "  [$status]"
    done

    # === NETWORK ===
    echo -e "\nNETWORK:"
    interface=$(ip route | grep default | awk '{print $5}')
    rx=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    sleep 1
    rx_new=$(cat /sys/class/net/$interface/statistics/rx_bytes)
    tx_new=$(cat /sys/class/net/$interface/statistics/tx_bytes)
    rx_rate=$(( (rx_new - rx) / 1024 ))
    tx_rate=$(( (tx_new - tx) / 1024 ))

    echo -en "  $interface (in) : ${rx_rate} KB/s "
    draw_bar $((rx_rate/100)) "OK"
    echo -en "  $interface (out): ${tx_rate} KB/s "
    draw_bar $((tx_rate/100)) "OK"

    # === LOAD AVERAGE ===
    echo -e "\nLOAD AVERAGE: $(uptime | awk -F'load average: ' '{print $2}')"

    # === RECENT ALERTS ===
    echo -e "\nRECENT ALERTS:"
    tail -n 5 "$LOG_FILE" 2>/dev/null || echo "No alerts yet."

    echo -e "\nPress 'h' for help, 'q' to quit"
}

# === KEY HANDLER ===
handle_keys() {
    read -rsn1 key
    case $key in
        q|Q) exit 0;;
        r|R)
            echo -ne "\nEnter new refresh rate (seconds): "
            read new_rate
            [[ $new_rate =~ ^[0-9]+$ ]] && REFRESH_RATE=$new_rate
            ;;
        f|F)
            FILTER="cpu/mem/disk/net/all"
            echo -ne "\nFilter options not implemented yet, keeping all."
            sleep 1
            ;;
        h|H)
            echo -e "\nShortcuts:\n  q: Quit\n  r: Change refresh rate\n  h: Help"
            sleep 2
            ;;
    esac
}

# === MAIN LOOP ===
while true; do
    draw_dashboard
    handle_keys &
    sleep "$REFRESH_RATE"
done