# 202 MusicServer (LXC)
- 2c/512M (cap 768M), 192.168.1.22 on vmbr1 (no VLAN tag).
- Lyrion Music Server :3483. Also: postfix :25, sshd :22.
- Mount: /pool/data/media/music → /mnt/data/
- Fixed 2026-11-01: removed stale lxc.cgroup2.blkio.weight (cgroup v1 setting
  on a cgroup v2 host — was blocking CT from starting). Reduced cores 4→2.
  Memory cap was 1536M (contradicting the 512M setting) → set to 768M.
- Baseline usage: ~150MB. Lean.
- In the all-excl-102/300 backup jobs.
