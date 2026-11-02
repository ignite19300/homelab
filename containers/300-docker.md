# 300 Docker (LXC)
- 2c/3GB (was 4c/4GB, tuned 2026-11-02), 192.168.10.30.
- arr stack + qBittorrent. Compose file: /root/docker-compose.yml (in CT).
- Running containers (7):
    sonarr      :8989  (TV)
    radarr      :7878  (movies)
    lidarr      :8686  (music)
    bazarr      :6767  (subtitles)
    prowlarr    :9696  (indexer manager)
    qbittorrent :8080  (download client, :6881 P2P)
    flaresolverr:8191  (torrent unblocker)
- REMOVED 2026-11-02: metube, audiobookshelf (moved to Kubuntu 103),
  calibre-web, scraper-app, vpn-sidecar (not needed).
- mem_limit in compose does NOT work (nested Docker in LXC lacks cgroup v2
  memory delegation). Containers run without explicit limits. CT-level
  memory cap (3GB) is the effective limit.
- Excluded from most vzdump jobs. Disabled stop-mode job remains.
- TUNNEL: torrents.example.com -> 192.168.10.30:8080 (qBittorrent UI).
  books.example.com -> 192.168.10.30:8083 is STALE (calibre-web removed).
  Remove the books tunnel entry in Cloudflare dashboard.
