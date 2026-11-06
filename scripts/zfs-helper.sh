#!/bin/bash
# ZFS helper — queries ZFS on PVE host (192.168.1.2) via SSH
# Usage: zfs-helper.sh <command>
# Commands: list, snapshots, pool <name>, pool, rpool

SSH="ssh -o ConnectTimeout=5 -o BatchMode=yes root@192.168.1.2"

case "$1" in
  list)
    $SSH "zfs list" 2>&1
    ;;
  snapshots)
    $SSH "zfs list -t snapshot | head -30" 2>&1
    ;;
  pool)
    $SSH "zpool status $2" 2>&1
    ;;
  pool)
    $SSH "zfs list -r pool" 2>&1
    ;;
  rpool)
    $SSH "zfs list -r rpool" 2>&1
    ;;
  *)
    echo "Usage: $0 {list|snapshots|pool <name>|pool|rpool}"
    ;;
esac
