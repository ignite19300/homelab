# Runbook: Re-point a Cloudflare Tunnel service

Tunnel config lives in CT 111 (Cloudflared, token-run mode — the token in
Cloudflare dashboard defines the named-tunnel ingress, NOT a local file).

1. Cloudflare dashboard → Networks → Tunnels → your tunnel → Public hostname.
2. Find the stale entry (e.g. `library.example.com` → 192.168.10.30:13378).
3. Edit service to the real target (e.g. 192.168.1.8:13378) → Save.
4. No restart of cloudflared needed — ingress changes apply live.
5. Test: curl the https URL, expect 200/302.
6. Update README tunnel table in this repo. Commit.

Known stale entries as of 2026-11-01:
- tube.example.com → should be 192.168.1.8:8081 (was 192.168.10.30:8081)
- library.example.com → should be 192.168.1.8:13378 (was 192.168.10.30:13378)
- books.example.com → 192.168.10.30:8083 — decide: move service or remove
- torrents.example.com → 192.168.10.30:8080 — decide: move service or remove
- jellyfin.example.com → 192.168.10.23:8096 — CT 203 stopped; fix or remove
