# Homelab Infrastructure

Self-hosted homelab: Proxmox VE host + pfSense firewall, exposing 12 services
via Cloudflare Tunnel under `*.example.com`. Single household, Berlin.

## What is this?

One physical Proxmox server (node `pve`, 192.168.1.2) running 4 VMs and 6 LXC
containers, fronted by a pfSense firewall (192.168.1.10). Services are reachable
internally by IP and externally via named Cloudflare Tunnel hosts.

## Nodes & guests

| ID | Name | Type | IP | Bridge | Role |
|----|------|------|----|--------|------|
| 100 | pfsense | VM | 192.168.1.10 | vmbr0 | Firewall, WAN/LAN |
| 101 | haos | VM | 192.168.1.11 | vmbr1 | Home Assistant OS |
| 102 | Windows11 | VM | 192.168.1.12 | vmbr1 | Personal Windows box (EXCLUDED from backups) |
| 103 | Kubuntu | VM | 192.168.1.8 | vmbr1 | AI stack + media (OpenWebUI, SearXNG, MetaTube, Audiobookshelf, ebook2audiobook) |
| 110 | VaultWarden | LXC | 192.168.10.10 | vmbr2/10 | Password manager (Alpine) |
| 111 | Cloudflared | LXC | 192.168.10.11 | vmbr2/10 | Cloudflare Tunnel (12 services) + postfix |
| 200 | FilesStack | LXC | 192.168.10.20 | vmbr2/10 | Samba :445, FileBrowser :8081, Radicale :5232, rclone WebDAV :8082 |
| 202 | MusicServer | LXC | 192.168.1.22 | vmbr1 | Lyrion Music Server :3483 (always-on music) |
| 203 | JellyFin | LXC | 192.168.10.23 | vmbr2/10 | Media server (currently stopped) |
| 300 | Docker | LXC | 192.168.10.30 | vmbr2/10 | Generic Docker host (stopped; candidate for deletion) |

> Note: LXC IPs shown are the stable ones from the IP map. `ip=dhcp` in
> .conf files means they get assigned by DHCP — the table records the
> observed/stable values.

## Network / subnets

- `vmbr0` = WAN/edge (pfSense lives here)
- `vmbr1` = main LAN (192.168.1.0/24) — Kubuntu, HA, Windows
- `vmbr2` tag 10 = service VLAN (192.168.10.0/24) — all LXC containers
- External access: Cloudflare Tunnel from CT 111, no ports exposed at the router

## Services exposed via Cloudflare Tunnel

| Host | Target | What |
|------|--------|------|
| proxmox.example.com | 192.168.1.2:8006 | PVE web UI |
| vault.example.com | 192.168.10.10:8000 | VaultWarden |
| torrents.example.com | 192.168.10.30:8080 | Torrent client (CT 300 - currently down) |
| jellyfin.example.com | 192.168.10.23:8096 | JellyFin (currently down) |
| cloud.example.com | 192.168.10.20:8082 | rclone WebDAV |
| ai.example.com | 192.168.1.8:3000 | OpenWebUI |
| tube.example.com | 192.168.1.8:8081 | MetaTube (container removed 2026-11-01 — tunnel stale) |
| contacts.example.com | 192.168.10.20:5232 | Radicale (CalDAV/CardDAV) |
| files.example.com | 192.168.10.20:8081 | FileBrowser |
| books.example.com | 192.168.10.30:8083 | ebooks (CT 300 - currently down) |
| library.example.com | 192.168.1.8:13378 | Audiobookshelf (container removed 2026-11-01 — tunnel stale) |
| search.example.com | 192.168.1.8:8080 | SearXNG |

**KNOWN ISSUE (2026-11-01):** CT 300 (Docker) is stopped, so tunnels targeting
192.168.10.30 are down: torrents, books, jellyfin (target 203 also stopped).
The `tube` and `library` tunnels were re-pointed to 192.168.1.8 on 2026-11-01,
but the metube/audiobookshelf containers were then REMOVED from Kubuntu
(rarely used; Kodi+Real-Debrid covers media). Those two tunnel entries are
stale — remove them in the Cloudflare dashboard, or re-deploy the containers
when needed. See `docs/runbooks/repoint-tunnel.md`.

## Backups (vzdump, all zstd, snapshot mode)

| Schedule | Scope | Target | Keep |
|----------|-------|--------|------|
| daily 03:00 | 110, 200 | External-Hdd | 10 |
| Mon 00:45 | all excl 102,300 | External-Hdd | 2 |
| Mon 01:00 | all excl 300 | backups (/pool) | 1 |
| Tue 03:00 | all excl 102,300 | backups | 2 |
| Thu 03:00 | all excl 102,300 | backups | 5 |
| Sun 02:45 | 300 (stop mode) | External-Hdd | 2 (disabled) |
| Sun 03:00 | all excl 102,300 | External-Hdd | 2 |

- 102 (Windows11) and 300 (Docker) are excluded from most jobs on purpose.
- Offsite: none yet (deferred). The git repo itself is offsite (GitHub private).

## Storage (Proxmox)

- `local` dir /var/lib/vz — templates, ISOs
- `local-zfs` rpool/data — VM/CT rootfs + images
- `pool` ZFS pool /pool — images
- `backups` /pool/backups — vzdump target (keep 10)
- `External-Hdd` /mnt/pve/External-Hdd — vzdump target (keep 4)

## Secrets

Never in this repo. All passwords/tokens live in VaultWarden (192.168.10.10).
Local-only `SECRETS.md` (git-ignored) lists where each secret lives.

## Layout of this repo

- `nodes/` — per VM/LXC notes + configs
- `nodes/pve-host/` — storage.cfg, jobs.cfg, VM/CT .conf files
- `nodes/103-kubuntu/docker/` — docker-compose files
- `docs/decisions.md` — why we made the major choices
- `docs/runbooks/` — restore, rebuild-CT, change-IP, repoint-tunnel, DR
