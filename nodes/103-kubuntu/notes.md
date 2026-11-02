# 103 Kubuntu (VM)
- 192.168.1.8 on vmbr1, 8 cores / 18GB. Docker host for AI + search stack.
- Running containers: open-webui :3000, searxng :8080, ebook2audiobook :7860,
  watchtower (auto-updates).
- REMOVED 2026-11-01: metube (was :8081), audiobookshelf (was :13378).
  Rationale: Kodi + Real-Debrid covers movies/series; audiobooks are
  infrequent. Tunnels for tube/library re-pointed to Kubuntu before removal
  (user confirmed working), then containers removed.
- This VM also hosts this documentation's working tree (~/homelab) and the
  OpenWebUI agent that manages the lab.
