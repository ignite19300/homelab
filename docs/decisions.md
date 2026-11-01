# Decisions Log (append-only)

One entry per major choice. Newest first. Do not edit old entries — add a new one if you reverse a decision.

## 2026-11-01
- **Offsite backup deferred.** No offsite target for now. Mitigation: the git
  repo (this repo) is offsite on GitHub (private) and covers all configs.
  Data (backups, media) remains on-site only (pool + External-Hdd).
  Accepting the risk knowingly.
- **Documentation = this repo.** No separate wiki. If it's not in the repo,
  it doesn't exist for documentation purposes. Secret values never committed;
  VaultWarden is the secret home.

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
