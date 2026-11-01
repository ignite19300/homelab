# Runbook: Restore a VM/LXC from backup

1. PVE UI → Datacenter → pve → Backups → find the vzdump job that covers
   the guest (see README backup table) → pick the newest .vzva.
2. Right-click → Restore → choose target VMID (same ID to overwrite, or new
   ID to restore alongside).
3. If restoring over a running guest: stop it first.
4. After restore: check the IP is back (LXC guests use DHCP — if the old
   lease is stale, the stable IP from the README table is the one to expect).
5. If the guest was on a stopped container (e.g. 300), also verify any
   tunnel entry pointing at it (README tunnel table).

CLI equivalent:
  qa_restore <vzva> <vmid>
