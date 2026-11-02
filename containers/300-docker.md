# 300 Docker (LXC)
- 2c/3GB, 192.168.10.30. **STOPPED (on-demand, 2026-11-02).**
- Reason: host is memory-constrained (~28GB/31GB active with 300 running).
  300 is used only occasionally (torrents for apps/music), so it's parked
  to free 3GB for headroom (JellyFin 8GB / Windows 12GB).

## To start it
  pct start 300
  (arrs re-scan on start; qBittorrent re-establishes P2P in ~30s.)

## Contents (7 containers, compose at /root/docker-compose.yml in CT)
    sonarr      :8989  (TV)
    radarr      :7878  (movies)
    lidarr      :8686  (music)
    bazarr      :6767  (subtitles)
    prowlarr    :9696  (indexer manager)
    qbittorrent :8080  (download client, :6881 P2P)
    flaresolverr:8191  (torrent unblocker)
- REMOVED 2026-11-02: metube, audiobookshelf (now on Kubuntu 103),
  calibre-web, scraper-app, vpn-sidecar.
- mem_limit in compose does NOT work (nested Docker in LXC lacks cgroup v2
  memory delegation). CT-level 3GB cap is the effective limit.
- Excluded from most vzdump jobs (disabled stop-mode job remains).
- TUNNELS (both DOWN while 300 stopped):
    torrents.example.com -> 192.168.10.30:8080 (qBittorrent) - valid when up
    books.example.com -> REMOVED from Cloudflare (calibre-web gone)

## Weekly auto-update (no watchtower)
- PVE host cron: `0 4 * * 0 /root/ct300-weekly-update.sh` (Sun 04:00)
- Script: starts CT 300, waits for Docker, runs `docker compose pull && up -d`, stops CT.
- Log: `/var/log/ct300-weekly-update.log` on PVE host.
- Script copy in repo: `scripts/ct300-weekly-update.sh`
