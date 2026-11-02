# 103 Kubuntu (VM)
- 192.168.1.8 on vmbr1. **20 cores / 21GB RAM** (raised from 8c/18GB on 2026-11-02).
  Docker host for AI + media stack. Primary daily-driver VM.

## Sizing / resources (2026-11-02)
- Host CPU: i5-13600K = 14 physical / 20 logical (6 P-cores x2 SMT + 8 E-cores).
- `cores: 20` in /etc/pve/qemu-server/103.conf (was 8). Windows 11 (102) is
  EXCLUDED from all resource math — it never runs while Kubuntu is the driver.
- RAM ceiling = 21GB: 31.1GB host - ~3GB (PVE+ZFS ARC) - 0.75GB pfSense -
  1.5GB HA - ~5GB running CTs = ~20.8GB free. 24GB rejected (overcommit).
- Guest agent: `agent: enabled=1` added to 103.conf (was absent entirely). PVE
  now reports real RAM usage. qemu-guest-agent 10.2.1 installed + enabled.
  NOTE: `qm set` CLI is broken on this host ("too many arguments") — edit
  /etc/pve/qemu-server/103.conf directly (backups .bak-20261102, .bak2-20261102).

## Performance tuning (2026-11-02) — all persistent
- **llama pinned to P-cores:** /usr/local/bin/llama-pin.sh waits 30s (6x5s)
  after boot for llama-server, then `taskset 0x0FFF` (12 P-cores, logical
  0-11). E-cores 12-19 stay free for desktop/apps. Driven by
  /etc/systemd/system/llama-pin.service (oneshot, RemainAfterExit, enabled).
  If llama is restarted manually, re-pin:
  `sudo taskset -p 0x0FFF $(pgrep -f llama-server|head -1)`
- **sysctl tuning** in /etc/sysctl.d/99-kubuntu-tuning.conf:
  - vm.vfs_cache_pressure = 50 (keep file/dir caches ~2x longer)
  - vm.dirty_ratio = 10, vm.dirty_background_ratio = 5 (smooth writeback,
    no I/O stall bursts)
- **swappiness** = 10 (live + /etc/sysctl.d/99-swappiness.conf).
- **Removed lms.service** (SqueezeboxServer): disabled, unit +
  /usr/share/squeezeboxserver + /var/lib/squeezeboxserver wiped
  (was crash-looping exit 203). The real Squeezebox is LXC CT 202.
- **Disabled junk services** (all confirmed inactive): libvirtd, ModemManager,
  cups, cups-browsed, rpcbind, geoclue, packagekit.
- **Left alone (correct as-is):** intel_pstate governor, THP=madvise,
  IO scheduler=none (NVMe-class), irqbalance off (avoids fighting the pin),
  snapd (Firefox is a snap), nvidia-persistenced (keeps LLM GPU clocks up),
  chrony, unattended-upgrades, avahi.

## Benchmark (2026-11-02, post-tuning)
- CPU single core (SHA-256): 1.57-2.41 GB/s per core (bimodal P/E as expected).
- CPU all 20 cores (SHA-256): **38.0 GB/s total** (~2.4x the old 8-core cap).
- RAM (dd via /dev/shm): 1.7 GB/s write / 1.9 GB/s read (single-stream).
- Disk (400GB virt, NVMe-backed via ZFS): **3.0 GB/s write / 6.0 GB/s read
  (direct)** — at the physical storage limit, nothing left to gain.

## Running containers
    open-webui      :3000  (AI chat / this agent)
    searxng         :8080  (privacy search)
    ebook2audiobook :7860  (ebook -> audiobook, GPU)
    metube          :8081  (alexta69/metube - YouTube frontend)
    audiobookshelf  :13378 (ghcr.io/advplyr/audiobookshelf, data home/user/audiobooks)
- watchtower removed 2026-11-02 (replaced by scripts/ct300-weekly-update.sh).
- History: metube + audiobookshelf were briefly removed 2026-11-02 (misread
  of user intent) then re-created the same day. Images cached locally.
- This VM also hosts this documentation's working tree (~/homelab/homelab-infra)
  and the OpenWebUI agent that manages the lab.
