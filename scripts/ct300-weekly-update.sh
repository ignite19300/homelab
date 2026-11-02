#!/bin/bash
# ct300-weekly-update.sh - Weekly container update for CT 300
# Starts CT 300, pulls + applies Docker Compose updates, then stops it.
# Lives on the PVE host at /root/ct300-weekly-update.sh
# Cron (PVE host): 0 4 * * 0 /root/ct300-weekly-update.sh
# Log: /var/log/ct300-weekly-update.log

LOG="/var/log/ct300-weekly-update.log"
CT="300"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting CT $CT for weekly update" >> "$LOG"

pct start "$CT" >> "$LOG" 2>&1
if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: Failed to start CT $CT" >> "$LOG"
    exit 1
fi

# Wait for Docker to be ready inside the CT (up to 60s)
for i in $(seq 1 30); do
    if pct exec "$CT" -- docker info >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

pct exec "$CT" -- sh -c "cd /root && docker compose pull && docker compose up -d" >> "$LOG" 2>&1
RC=$?

pct stop "$CT" >> "$LOG" 2>&1

if [ $RC -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SUCCESS: CT $CT updated and stopped" >> "$LOG"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Update failed (rc=$RC), CT $CT stopped" >> "$LOG"
fi
