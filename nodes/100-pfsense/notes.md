# 100 pfSense (VM)
- IP 192.168.1.10 on vmbr0 (edge). Admin UI: http://192.168.1.10, creds in VaultWarden.
- SSH to pfSense is NOT enabled (connection timed out 2026-11-01) — config.xml
  cannot be pulled via scp. TODO: export config.xml from the pfSense GUI
  (Diagnostics → Backup/Restore) and drop the REDACTED copy in this dir.
- Roles: WAN/LAN split, DHCP for LAN, NAT rules. pfSense is a SPOF —
  recovery = rebuild VM + import config.xml (see docs/runbooks/disaster-recovery.md).
