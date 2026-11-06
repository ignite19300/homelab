## 2026-11-06
- **llama.cpp router mode.** Replaced the old two-server setup (separate 27B + 8B
  llama-servers + custom Python router on :8900) with a SINGLE llama-server in
  ROUTER MODE on :9931, managed by systemd `llama-router.service` (enabled,
  Restart=always). Models dir home/user/llama-server-router/ with models.ini
  preset (n-gpu-layers 99, c 91136, flash-attn on, q4_0 KV cache, temp 0.6,
  top-p 0.85, top-k 20, min-p 0.05). 27B (IQ3_S + MTP draft, spec-type draft-mtp,
  load-on-startup) + Qwen3-VL-8B vision (loaded on demand). Rationale: one
  process, native model switching, no custom Python glue to maintain.
- **HA LLM recovery cards** (nodes/103-kubuntu/ha/): shell_commands over SSH
  (start llama/OWUI/router, status checks) + dashboard action cards + optional
  port sensor. Router start now targets llama-router.service on :9931.

## 2026-11-02 (later)
- **CT 300 parked (stopped) on-demand.** Host is memory-constrained: with
  300 running the active total is ~28GB of 31GB, leaving no headroom for
  JellyFin (8GB) or Windows (12GB). 300 (arr stack + qBittorrent) is used
  only occasionally, so it is stopped to free 3GB. Start with `pct start 300`
  when needed. This is the standing policy: memory-hungry on-demand services
  stay stopped.

## 2026-11-02 (final) - Kubuntu (103) full optimization pass
- **Kubuntu gets 20 cores / 21GB RAM.** vCPUs are ceilings, not reservations -
  the host scheduler shares all threads on demand. Windows 11 is excluded
  from all resource math (never counted as a running VM). 24GB RAM rejected:
  21GB is already the ceiling (host fully allocated at ~30.7 of 31.1GB).
- **Guest agent added** (`agent: enabled=1` in 103.conf - it was missing
  entirely, which is why the guest service failed with a dependency error).
- **llama-server pinned to the 12 P-cores** (taskset 0x0FFF, boot service
  llama-pin.service). E-cores stay free for the desktop. Rationale: LLM is
  the heaviest workload; P-cores run ~5.1GHz vs ~3.5GHz on E.
- **Removed SqueezeboxServer (lms.service)** from Kubuntu - it was a
  crash-looping duplicate of the real music server (LXC CT 202).
- **Disabled 7 junk services** (libvirtd, ModemManager, cups, cups-browsed,
  rpcbind, geoclue, packagekit) - none needed on this box.
- **sysctl tuning** persisted: vfs_cache_pressure=50, dirty_ratio=10,
  dirty_background_ratio=5, swappiness=10.
- Result: 38 GB/s aggregate CPU (2.4x old), disk at physical limit
  (3.0/6.0 GB/s), RAM hot with no swap pressure.

## 2026-11-01
- **Offsite backup deferred.** No offsite target for now. Mitigation: the git
  repo (this repo) is offsite on GitHub (private) and covers all configs.
  Data (backups, media) remains on-site only (pool + External-Hdd).
  Accepting the risk knowingly.
- **Documentation = this repo.** No separate wiki. If it's not in the repo,
  it doesn't exist for documentation purposes. Secret values never committed;
  VaultWarden is the secret home.

## 2026-11-06
- **pfBlockerNG threat-blocking brought online.** 3.2.17 active with ~17.3K IP
  entries (CINS/ET/Spamhaus/ISC/Talos/Abuse) in `pfB_PRI1_v4`, verified live
  on LAN + OPT. This closes the main inbound-threat gap. pfBlockerNG DNSBL is
  enabled in config but NOT wired (lighty not running, Unbound not pointed at
  it) -> ad/malware-domain blocking is a P1 TODO, not done.
- **mesh VPN fully removed** from pfSense (proc/iface/rules gone). The
  Squeezebox (192.168.1.62) still hammers the dead mesh VPN peer 100.64.0.1:9000,
  inflating the pf state table ~63% stale -> P1 block-rule TODO.
- **Documentation discipline:** a single `docs/TODO.md` is now the backlog /
  "things to do later" source of truth, tiered P1/P2/P3/IDEA. pfSense notes
  moved to the 2.9 config path (`/cf/conf/config.xml`).

## Earlier (reconstructed from current state)
- **Proxmox VE as the hypervisor.** Free, VMs + LXC in one tool, built-in
  vzdump backups, web UI. Chosen over ESXi (paid, no LXC) and bare metal.
- **pfSense as edge firewall.** Dedicated VM (100) on vmbr0. Chosen over
  pve-firewall because: full GUI, NAT rules, VPN-ready, isolated from the
  Proxmox host itself.
- **Self-hosted + Cloudflare Tunnel** instead of a public IP / port
  forwarding. Rationale: no exposed ports at the router, TLS handled by
  Cloudflare, works from anywhere, free. Cost: a dependency on Cloudflare +
  one small LXC (111) as the tunnel process host.
- **ZFS (rpool + pool)** for storage: snapshots, checksumming, easy growth.
- **Two backup targets, staggered** (pool/backups + External-Hdd) with
  different keep-counts per weekday = a poor man's GFS rotation without
  a third disk. 102 (Windows) and 300 (Docker) excluded to save time/space;
  300 had a disabled stop-mode job left behind.
- **LXC for stateless-ish services, VM for things that need one** (pfSense
  needs a real NIC stack; Windows obviously; Kubuntu hosts Docker + AI stack).
- **Kubuntu (103) as the Docker host for AI + media** — moved off CT 300 at
  some point (CT 300 now stopped). Consequence: tunnel entries for
  tube/library/books may still point at CT 300's IP. See known issue in README.
