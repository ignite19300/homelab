# Homelab Infrastructure — Portfolio

Self-hosted homelab: **Proxmox VE** host + **pfSense** firewall, exposing 12
services via **Cloudflare Tunnel**. Single household, Berlin.

> **Note:** This is a sanitized portfolio copy. All real IPs, MAC addresses,
> UUIDs, domain names, VPN details, and user-specific references have been
> replaced with generic placeholders. The architecture, configs, runbooks,
> and documentation are authentic — only identifying details are omitted.

## What's here

| Section | Contents |
|---------|----------|
| `README.md` | Full node/guest table, network layout, tunnel map, backup schedule, storage |
| `nodes/` | Per-VM/LXC notes, Proxmox `.conf` files, pfSense security audit |
| `containers/` | LXC container docs (VaultWarden, Cloudflared, FilesStack, MusicServer, JellyFin, Docker) |
| `docs/` | Architecture decisions, tiered TODO/backlog, runbooks (DR, rebuild, repoint, restore) |
| `scripts/` | Helper scripts (Docker, ZFS, weekly container updates) |

## Infrastructure at a glance

- **1 physical server** → 4 VMs + 6 LXC containers on Proxmox VE
- **pfSense** — WAN/LAN split, pfBlockerNG, Unbound, WireGuard VPN, Cloudflare Tunnel (no open ports)
- **12 services** exposed via named tunnel hosts (password manager, media, AI, files, search, etc.)
- **ZFS** storage with scheduled vzdump backups (snapshot + stop mode)
- **Home Assistant** with LLM recovery shell commands, dashboard cards, MCP server
- **AI stack** — local LLM router (27B + 8B vision), OpenWebUI, STT/TTS (Whisper + Kokoro/Piper)

## Why this repo exists

Documented the full infrastructure so it's recoverable from a single git repo.
Every node, container, backup job, tunnel, and security rule is captured with
enough detail to rebuild from scratch. The runbooks cover disaster recovery,
CT rebuilds, tunnel re-pointing, and backup restoration.

## Sanitization

| Replaced | Example |
|----------|---------|
| Real IPs → | `192.168.x.x` / `203.0.113.x` |
| MAC addresses → | `52:54:00:AA:00:xx` |
| UUIDs → | `1111...` / `2222...` |
| Domain → | `*.example.com` |
| VPN / mesh names → | Generic |
| User paths / names → | `user` |
| ZFS pool name → | `pool` |
