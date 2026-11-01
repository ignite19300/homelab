# Runbook: Full disaster recovery (PVE host dies)

Order of operations — do not skip ahead:

1. **Configs**: this repo (GitHub) has storage.cfg, jobs.cfg, all VM/CT
   .conf files. pfSense redacted config.xml in nodes/100-pfsense/.
2. **Secrets**: VaultWarden — the LAST backup of its DB is in vzdump 110
   (daily 03:00 → External-Hdd, keep 10). Restore 110 first if its backup
   is on a surviving target.
3. **New host**: install Proxmox, set node name `pve`, IP 192.168.1.2 (or new
   IP + update pfSense/README).
4. **Storage**: recreate storage.cfg from repo. If old disks survived,
   import the ZFS pool (zpool import) — data follows the disks, not the host.
5. **pfSense**: install pfSense on NIC 1, import redacted config.xml,
   re-enter admin password from VaultWarden.
6. **Guests**: restore from vzdump (see restore-backup.md). Order: 100 done
   in step 5, then 110, 111, 200, 103, 202, then 203/300 only if wanted.
7. **Tunnels**: cloudflared in 111 re-runs with the same token → all named
   hosts come back automatically once targets are up.
8. **Verify**: walk the README tunnel table, curl each host.
9. **Commit** any config changes to this repo.

Worst case (all disks dead): configs from repo + secrets from the last
VW backup + data from... nothing. This is the accepted risk (see decisions.md).
