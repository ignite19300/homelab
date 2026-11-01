# Runbook: Rebuild an LXC container from scratch

Use when a CT's rootfs is corrupted beyond repair.

1. Read the CT's `nodes/pve-host/lxc/<id>.conf` in this repo — that is the
   source of truth for cores/memory/rootfs size/bridge/tag.
2. Read the CT's `containers/<id>-<name>/conf.md` — what software it runs
   and how to configure it.
3. PVE UI → node → CTs → Create: same VMID, same template image, same
   resources from the .conf.
4. Re-apply the network: correct bridge + VLAN tag (vmbr2 tag 10 for most).
5. Install software per conf.md. Re-enter secrets from VaultWarden (never from
   this repo).
6. Verify: `pct status <id>` = running, service port answers, tunnel entry
   (if any) resolves.
7. Update the .conf in this repo if anything changed, and commit.
