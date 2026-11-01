# 103 Kubuntu (VM)
- 192.168.1.8 on vmbr1, 8 cores / 18GB. Docker host for AI + media stack.
- Running containers: open-webui :3000, searxng :8080, metube :8081,
  audiobookshelf :13378, ebook2audiobook :7860, watchtower (auto-updates).
- This VM also hosts this documentation's working tree (~/homelab) and the
  OpenWebUI agent that manages the lab.
- compose files live in nodes/103-kubuntu/docker/ (commit them when created
  — several containers were started from CLI flags, not compose, yet).
