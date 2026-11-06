# 100 pfSense (VM)

- **IP:** 192.168.1.1 on vmbr1 (LAN/edge). WAN = PPPoE on vtnet0.7 (VLAN 7) -> 203.0.113.1, MTU 1492.
- **Admin UI:** http://192.168.1.1. SSH is enabled (root, key auth). pfSense 2.9.0 (FreeBSD 16.0-CURRENT).
- **Config file:** `/cf/conf/config.xml` (pfSense 2.9 layout — NOT the old `/etc/pfSense.xml`).
- **Roles:** WAN/LAN split, DHCP, NAT, firewall, VPN, DNS, threat-blocking.
- pfSense is a SPOF — recovery = rebuild VM + import config.xml (docs/runbooks/disaster-recovery.md).

## Security stack (verified live 2026-11-06)

| Layer | State |
|-------|-------|
| **pfBlockerNG 3.2.17** | ACTIVE. ~17.3K IP entries in `pfB_PRI1_v4` (CINS_army, ET_Block, ET_Comp, Spamhaus_Drop/eDrop, ISC_Block, Talos, Abuse Feodo/SSLBL). Block mode `block return`, applied to LAN + OPT. Verified: feed IP present in live pf table. |
| **pfBlockerNG DNSBL** | ENABLED in config (`pfb_dnsbl=on`, `dnsbl_mode=dnsbl_unbound`, lo0, ports 8081/8443) but **lighty service not running** and **Unbound not wired to it** -> ad/malware domains NOT actually blocked. See TODO. |
| **Unbound** | Local recursive resolver, DNSSEC validation, forwards to 1.1.1.1 + WireGuard VPN 192.168.2.1. |
| **Unbound RPZ (internal names)** | **Working.** `host_entries.conf` auto-generated from DHCP statics: all 32 hosts (LAN + OPT) as `local-data` A + PTR. Verified `Home_Assistant.example.com -> 192.168.1.5`. |
| **WAN hardening** | SSH/telnet blocked from WAN, bogon + private-net anti-spoof enabled. |
| **SSH** | sshguard active; key-based path. (fail2ban-style throttling observed on rapid reconnects.) |
| **VPN** | WireGuard VPN WireGuard `tun_wg0` 192.168.2.2/32, full-tunnel. Kill-switch rules active (LAN + OPT). |
| **Remote access** | Cloudflared tunnel (CT 111) — no ports exposed at the router. mesh VPN fully removed (no proc/iface/rules). |

- **Firewall rules:** 23. **NAT port-forwards:** 0 (clean).
- **Interfaces:** vtnet0 = WAN PPPoE (203.0.113.1), vtnet1 = LAN (192.168.1.1), vtnet2.10 = containers (192.168.10.1) + 192.168.2.2 (WG).

## Known issues / pending
See **docs/TODO.md** (single source of truth). pfSense-specific:
- Squeezebox Radio (192.168.1.62) flooding dead mesh VPN peer 100.64.0.1:9000 -> ~2,300+ stale pf states (63% of state table). Block rule pending.
- pfBlockerNG DNSBL not functional (enabled but not wired).
- Optional: Suricata (IDS) — deferred, needs 2 vCPU first.
