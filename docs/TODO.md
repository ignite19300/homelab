# TODO / Backlog

Single source of truth for "things to do or fix later." Newest first within each tier.
Tiers: **P1** = do soon (real benefit / active problem), **P2** = when convenient,
**P3** = optional / nice-to-have, **IDEA** = not committed.

Last updated: 2026-11-06

---

## P1 — do soon

- [ ] **Block the Squeezebox -> dead mesh VPN peer spam (pfSense).**
  `192.168.1.62` (Squeezebox Radio) is flooding the now-dead mesh VPN peer
  `100.64.0.1:9000`, creating ~2,300+ perpetual pf states (~63% of the
  state table). Add a LAN block rule: Block / TCP / src 192.168.1.62 /
  dst 100.64.0.1. Dips the state table from ~3,783 to ~1,400.
  (Better long-term: remove the mesh VPN/app connection on the device itself.)

- [ ] **Get pfBlockerNG DNSBL actually working (pfSense).**
  It is enabled in config (`pfb_dnsbl=on`, unbound mode) but the lighty
  DNSBL service is not running and Unbound is not pointed at it — so
  ad/tracker/malware domains are NOT blocked. Enable cleanly via GUI
  (Firewall -> pfBlockerNG -> DNSBL) so the package starts lighty on 8081
  and regenerates unbound.conf. Verify `doubleclick.net -> 0.0.0.0` after.
  (Do NOT hand-edit unbound.conf — it gets overwritten on next sync.)

- [ ] **Rotate / renew the GitHub PAT before 2027-01-31.**
  Stored in `~/.git-credentials` on Kubuntu 103 (HTTPS). New classic PAT
  with `repo` scope, overwrite the file, chmod 600. Calendar reminder set 2027-01-24.

---

## P2 — when convenient

- [ ] **HA entity cleanup (2026-11-03 audit).** Disable 170 stale Browser Mod
  entities (13 dead media_players + sensors), 29 Desktop Linux (Fedora PC),
  21 `none_*` Marantz orphans, 6 broken automations (bathroom/kitchen/
  living_room_light_control, grow_tent x2, mqtt_topic_standardization),
  8 never-triggered (Blu-ray remote x5, dup morning routines x2, smoke silence).
  See note: "Home Assistant Deep Audit & Optimization Plan (2026-11-03)".

- [ ] **HA updates pending:** cloudflared 7.0.21, esphome 2026.10.2.

- [ ] **HA voice:** make wyoming/speaches the primary STT/TTS (OpenAI STT/TTS
  currently showing "unknown").

- [ ] **pfSense optional cleanups:**
  - Re-consolidate the 10 `Allow Browsing` LAN rules into 1 port-group rule.
  - Confirm the 2 orphaned WAN NAT entries (192.168.10.30:33282 tcp+udp) are
    gone / not needed (NAT port-forward count now reports 0).
  - `192.168.1.22` MusicServer rule — host offline, 0 traffic; review.

- [ ] **Kubuntu 103:** re-run `docker network connect voice_default open-webui`
  if the open-webui container is ever deleted/recreated (network link is not
  persistent across recreation).

- [ ] **Kubuntu 103 Docker disk:** ~27 GB reclaimable (duplicate open-webui
  images latest/main/v0.12.5). `watchtower` container is DEAD (exited).

- [ ] **CT 300 (Docker) + CT 203 (JellyFin) are stopped** on-demand. When
  started, confirm tunnel targets (torrents/books/jellyfin -> 192.168.10.30 / .23)
  resolve correctly. tube + library already re-pointed to 192.168.1.8.

- [ ] **Backup posture:** no offsite backup, no PBS/dedup. Accepting risk
  (git repo is offsite for configs; data is on-site only). Revisit if pool grows.

---

## P3 — optional / nice-to-have

- [ ] **Suricata (IDS) on pfSense.** Detection layer (pfBlockerNG is prevention
  only). Requires bumping pfSense to 2 vCPU first (currently 1). Revisit only
  if services get exposed directly to the internet or forensic visibility wanted.

- [ ] **Unbound RPZ for `*.example.com`.** ALREADY DONE via auto-generated
  host_entries.conf (all 32 hosts). Listed here only to confirm no action needed.

- [ ] **Pin llama-server to P-cores from host side** (taskset on QEMU proc) —
  guest-side llama-pin.service already does this; host-side is a fallback only.

- [ ] **Offsite backup** for pool/External-Hdd data (restic/borg to a remote).

---

## IDEA — not committed

- Proxmox Backup Server (PBS) to replace dir-based vzdump for dedup + offsite.
- Second WAN / failover (overkill for home).
- Squid proxy on pfSense (obsolete with HTTPS everywhere — skip).
